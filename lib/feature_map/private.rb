# frozen_string_literal: true

# typed: strict

require 'feature_map/private/extension_loader'
require 'feature_map/private/cyclomatic_complexity_calculator'
require 'feature_map/private/feature_metrics_calculator'
require 'feature_map/private/assignments_file'
require 'feature_map/private/metrics_file'
require 'feature_map/private/glob_cache'
require 'feature_map/private/feature_assigner'
require 'feature_map/private/feature_plugins/assignment'
require 'feature_map/private/validations/files_have_features'
require 'feature_map/private/validations/features_up_to_date'
require 'feature_map/private/validations/files_have_unique_features'
require 'feature_map/private/assignment_mappers/file_annotations'
require 'feature_map/private/assignment_mappers/feature_globs'
require 'feature_map/private/assignment_mappers/directory_assignment'
require 'feature_map/private/assignment_mappers/feature_definition_assignment'

module FeatureMap
  module Private
    extend T::Sig

    sig { returns(Configuration) }
    def self.configuration
      @configuration ||= T.let(@configuration, T.nilable(Configuration))
      @configuration ||= Configuration.fetch
    end

    # This is just an alias for `configuration` that makes it more explicit what we're doing instead of just calling `configuration`.
    # This is necessary because configuration may contain extensions of feature map, so those extensions should be loaded prior to
    # calling APIs that provide feature assignment information.
    sig { returns(Configuration) }
    def self.load_configuration!
      configuration
    end

    sig { void }
    def self.bust_caches!
      @configuration = nil
      @tracked_files = nil
      @glob_cache = nil
    end

    sig { params(files: T::Array[String], autocorrect: T::Boolean, stage_changes: T::Boolean).void }
    def self.validate!(files:, autocorrect: true, stage_changes: true)
      AssignmentsFile.update_cache!(files) if AssignmentsFile.use_features_cache?

      errors = Validator.all.flat_map do |validator|
        validator.validation_errors(
          files: files,
          autocorrect: autocorrect,
          stage_changes: stage_changes
        )
      end

      if errors.any?
        errors << 'See https://github.com/Beyond-Finance/feature_map#README.md for more details'
        raise InvalidFeatureMapConfigurationError.new(errors.join("\n")) # rubocop:disable Style/RaiseArgs
      end

      MetricsFile.write!
    end

    # Returns a string version of the relative path to a Rails constant,
    # or nil if it can't find something
    sig { params(klass: T.nilable(T.any(T::Class[T.anything], Module))).returns(T.nilable(String)) }
    def self.path_from_klass(klass)
      if klass
        path = Object.const_source_location(klass.to_s)&.first
        (path && Pathname.new(path).relative_path_from(Pathname.pwd).to_s) || nil
      else
        nil
      end
    rescue NameError
      nil
    end

    #
    # The output of this function is string pathnames relative to the root.
    #
    sig { returns(T::Array[String]) }
    def self.tracked_files
      @tracked_files ||= T.let(@tracked_files, T.nilable(T::Array[String]))
      @tracked_files ||= Dir.glob(configuration.assigned_globs) - Dir.glob(configuration.unassigned_globs)
    end

    sig { params(file: String).returns(T::Boolean) }
    def self.file_tracked?(file)
      # Another way to accomplish this is
      # (Dir.glob(configuration.assigned_globs) - Dir.glob(configuration.unassigned_globs)).include?(file)
      # However, globbing out can take 5 or more seconds on a large repository, dramatically slowing down
      # invocations to `bin/featuremap validate --diff`.
      # Using `File.fnmatch?` is a lot faster!
      in_assigned_globs = configuration.assigned_globs.any? do |assigned_glob|
        File.fnmatch?(assigned_glob, file, File::FNM_PATHNAME | File::FNM_EXTGLOB)
      end

      in_unassigned_globs = configuration.unassigned_globs.any? do |unassigned_glob|
        File.fnmatch?(unassigned_glob, file, File::FNM_PATHNAME | File::FNM_EXTGLOB)
      end
      in_assigned_globs && !in_unassigned_globs && File.exist?(file)
    end

    sig { params(feature_name: String, location_of_reference: String).returns(CodeFeatures::Feature) }
    def self.find_feature!(feature_name, location_of_reference)
      found_feature = CodeFeatures.find(feature_name)
      if found_feature.nil?
        raise StandardError, "Could not find feature with name: `#{feature_name}` in #{location_of_reference}. Make sure the feature is one of `#{CodeFeatures.all.map(&:name).sort}`"
      else
        found_feature
      end
    end

    sig { returns(GlobCache) }
    def self.glob_cache
      @glob_cache ||= T.let(@glob_cache, T.nilable(GlobCache))
      @glob_cache ||= if AssignmentsFile.use_features_cache?
                        AssignmentsFile.to_glob_cache
                      else
                        Mapper.to_glob_cache
                      end
    end
  end

  private_constant :Private
end
