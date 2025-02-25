# frozen_string_literal: true

# typed: strict

require 'code_ownership'
require 'csv'

require 'feature_map/constants'
require 'feature_map/private/extension_loader'
require 'feature_map/private/cyclomatic_complexity_calculator'
require 'feature_map/private/lines_of_code_calculator'
require 'feature_map/private/todo_inspector'
require 'feature_map/private/feature_metrics_calculator'
require 'feature_map/private/assignments_file'
require 'feature_map/private/assignment_applicator'
require 'feature_map/private/metrics_file'
require 'feature_map/private/glob_cache'
require 'feature_map/private/feature_assigner'
require 'feature_map/private/documentation_site'
require 'feature_map/private/code_cov'
require 'feature_map/private/test_coverage_file'
require 'feature_map/private/test_pyramid_file'
require 'feature_map/private/additional_metrics_file'
require 'feature_map/private/feature_plugins/assignment'
require 'feature_map/private/validations/files_have_features'
require 'feature_map/private/validations/features_up_to_date'
require 'feature_map/private/validations/files_have_unique_features'
require 'feature_map/private/assignment_mappers/file_annotations'
require 'feature_map/private/assignment_mappers/feature_globs'
require 'feature_map/private/assignment_mappers/directory_assignment'
require 'feature_map/private/assignment_mappers/feature_definition_assignment'
require 'feature_map/private/release_notification_builder'

module FeatureMap
  module Private
    extend T::Sig

    FeatureName = T.type_alias { String }
    FileList = T.type_alias { T::Array[String] }
    FeatureFiles = T.type_alias do
      T::Hash[
        FeatureName,
        FileList
      ]
    end

    sig { params(assignments_file_path: String).void }
    def self.apply_assignments!(assignments_file_path)
      assignments = CSV.read(assignments_file_path)
      AssignmentApplicator.apply_assignments!(assignments)
    end

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

    sig { params(git_ref: T.nilable(String)).void }
    def self.generate_docs!(git_ref)
      feature_assignments = AssignmentsFile.load_features!
      feature_metrics = MetricsFile.load_features!

      # Generating the test pyramid involves collecting dry-run coverage from rspec for unit, integration,
      # and regression tests.  This can be difficult to gather, so we allow for the docs site to be built
      # without it.
      feature_test_pyramid = TestPyramidFile.path.exist? ? TestPyramidFile.load_features! : {}

      # Test coverage data can be onerous to load (e.g. generating a CodeCov token, etc). Allow engineers to generate
      # and review the feature documentation without this data.
      feature_test_coverage = TestCoverageFile.path.exist? ? TestCoverageFile.load_features! : {}

      # Additional metrics must be calculated after the initial metrics are loaded
      feature_additional_metrics = AdditionalMetricsFile.path.exist? ? AdditionalMetricsFile.load_features! : {}

      DocumentationSite.generate(
        feature_assignments,
        feature_metrics,
        feature_test_coverage,
        feature_test_pyramid,
        feature_additional_metrics,
        configuration.raw_hash,
        T.must(git_ref || configuration.repository['main_branch'])
      )
    end

    sig do
      params(
        unit_path: String,
        integration_path: String,
        regression_path: T.nilable(String),
        regression_assignments_path: T.nilable(String)
      ).void
    end
    def self.generate_test_pyramid!(unit_path, integration_path, regression_path, regression_assignments_path)
      unit_examples = JSON.parse(File.read(unit_path))&.fetch('examples')
      integration_examples = JSON.parse(File.read(integration_path))&.fetch('examples')
      regression_examples = regression_path ? JSON.parse(File.read(regression_path))&.fetch('examples') : []
      regression_assignments = regression_assignments_path ? YAML.load_file(regression_assignments_path) : {}
      TestPyramidFile.write!(unit_examples, integration_examples, regression_examples, regression_assignments)
    end

    sig { params(commit_sha: String, code_cov_token: String).void }
    def self.gather_test_coverage!(commit_sha, code_cov_token)
      coverage_stats = CodeCov.fetch_coverage_stats(commit_sha, code_cov_token)

      TestCoverageFile.write!(coverage_stats)
    end

    sig { void }
    def self.generate_additional_metrics!
      feature_metrics = MetricsFile.load_features!
      feature_test_coverage = TestCoverageFile.path.exist? ? TestCoverageFile.load_features! : {}

      AdditionalMetricsFile.write!(feature_metrics, feature_test_coverage, configuration.raw_hash['documentation_site']['health'])
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

    sig { returns(FeatureFiles) }
    def self.feature_file_assignments
      glob_cache.raw_cache_contents.values.each_with_object(T.let({}, FeatureFiles)) do |assignment_map_cache, feature_files|
        assignment_map_cache.to_h.each do |path, feature|
          feature_files[feature.name] ||= T.let([], FileList)
          files = Dir.glob(path).reject { |glob_entry| File.directory?(glob_entry) }
          files.each { |file| T.must(feature_files[feature.name]) << file }
        end

        feature_files
      end
    end

    sig { params(feature: CodeFeatures::Feature).returns(T::Array[CodeTeams::Team]) }
    def self.all_teams_for_feature(feature)
      return [] if configuration.skip_code_ownership

      feature_assignments = AssignmentsFile.load_features!

      feature_files = feature_assignments.dig(feature.name, AssignmentsFile::FILES_KEY)
      return [] if !feature_files || feature_files.empty?

      feature_files.map { |file| CodeOwnership.for_file(file) }.compact.uniq
    end

    sig { params(commits_by_feature: CommitsByFeature).returns(ReleaseNotificationBuilder::BlockKitPayload) }
    def self.generate_release_notification(commits_by_feature)
      ReleaseNotificationBuilder.build(commits_by_feature)
    end
  end

  private_constant :Private
end
