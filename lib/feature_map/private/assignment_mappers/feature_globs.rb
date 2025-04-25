# frozen_string_literal: true

module FeatureMap
  module Private
    module AssignmentMappers
      class FeatureGlobs
        include Mapper
        include Validator

        @@map_files_to_features = @map_files_to_features # rubocop:disable Style/ClassVars
        @@map_files_to_features = {} # rubocop:disable Style/ClassVars

        def map_files_to_features(files)
          return @@map_files_to_features if @@map_files_to_features&.any?

          @@map_files_to_features = FeatureMap::CodeFeatures.all.each_with_object({}) do |feature, map| # rubocop:disable Style/ClassVars
            FeaturePlugins::Assignment.for(feature).assigned_globs.each do |glob|
              Dir.glob(glob).each do |filename|
                map[filename] = feature
              end
            end
          end
        end

        MappingContext = Struct.new(:glob, :feature, keyword_init: true)
        GlobOverlap = Struct.new(:mapping_contexts, keyword_init: true) do
          def description
            # These are sorted only to prevent non-determinism in output between local and CI environments.
            sorted_contexts = mapping_contexts.sort_by { |context| context.feature.config_yml.to_s }
            description_args = sorted_contexts.map do |context|
              "`#{context.glob}` (from `#{context.feature.config_yml}`)"
            end

            description_args.join(', ')
          end
        end

        def find_overlapping_globs
          mapped_files = {}
          FeatureMap::CodeFeatures.all.each_with_object({}) do |feature, _map|
            FeaturePlugins::Assignment.for(feature).assigned_globs.each do |glob|
              Dir.glob(glob).each do |filename|
                mapped_files[filename] ||= []
                mapped_files[filename] << MappingContext.new(glob: glob, feature: feature)
              end
            end
          end

          overlaps = []
          mapped_files.each_value do |mapping_contexts|
            if mapping_contexts.count > 1
              overlaps << GlobOverlap.new(mapping_contexts: mapping_contexts)
            end
          end

          overlaps.uniq do |glob_overlap|
            glob_overlap.mapping_contexts.map do |context|
              [context.glob, context.feature.name]
            end
          end
        end

        def map_file_to_feature(file)
          map_files_to_features([file])[file]
        end

        def update_cache(cache, files)
          globs_to_feature(files)
        end

        def globs_to_feature(files)
          FeatureMap::CodeFeatures.all.each_with_object({}) do |feature, map|
            FeaturePlugins::Assignment.for(feature).assigned_globs.each do |assigned_glob|
              map[assigned_glob] = feature
            end
          end
        end

        def bust_caches!
          @@map_files_to_features = {} # rubocop:disable Style/ClassVars
        end

        def description
          'Feature-specific assigned globs'
        end

        def validation_errors(files:, autocorrect: true, stage_changes: true)
          overlapping_globs = AssignmentMappers::FeatureGlobs.new.find_overlapping_globs

          errors = []

          if overlapping_globs.any?
            errors << <<~MSG
              `assigned_globs` cannot overlap between features. The following globs overlap:

              #{overlapping_globs.map { |overlap| "- #{overlap.description}" }.join("\n")}
            MSG
          end

          errors
        end
      end
    end
  end
end
