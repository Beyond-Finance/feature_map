# frozen_string_literal: true

# typed: true

module FeatureMap
  module Private
    module AssignmentMappers
      class FeatureGlobs
        extend T::Sig
        include Mapper
        include Validator

        @@map_files_to_features = T.let(@map_files_to_features, T.nilable(T::Hash[String, FeatureMap::CodeFeatures::Feature])) # rubocop:disable Style/ClassVars
        @@map_files_to_features = {} # rubocop:disable Style/ClassVars

        sig do
          params(files: T::Array[String])
          .returns(T::Hash[String, FeatureMap::CodeFeatures::Feature])
        end
        def map_files_to_features(files)
          return @@map_files_to_features if @@map_files_to_features&.keys && @@map_files_to_features.keys.count.positive?

          @@map_files_to_features = FeatureMap::CodeFeatures.all.each_with_object({}) do |feature, map| # rubocop:disable Style/ClassVars
            FeaturePlugins::Assignment.for(feature).assigned_globs.each do |glob|
              Dir.glob(glob).each do |filename|
                map[filename] = feature
              end
            end
          end
        end

        class MappingContext < T::Struct
          const :glob, String
          const :feature, FeatureMap::CodeFeatures::Feature
        end

        class GlobOverlap < T::Struct
          extend T::Sig

          const :mapping_contexts, T::Array[MappingContext]

          sig { returns(String) }
          def description
            # These are sorted only to prevent non-determinism in output between local and CI environments.
            sorted_contexts = mapping_contexts.sort_by { |context| context.feature.config_yml.to_s }
            description_args = sorted_contexts.map do |context|
              "`#{context.glob}` (from `#{context.feature.config_yml}`)"
            end

            description_args.join(', ')
          end
        end

        sig do
          returns(T::Array[GlobOverlap])
        end
        def find_overlapping_globs
          mapped_files = T.let({}, T::Hash[String, T::Array[MappingContext]])
          FeatureMap::CodeFeatures.all.each_with_object({}) do |feature, _map|
            FeaturePlugins::Assignment.for(feature).assigned_globs.each do |glob|
              Dir.glob(glob).each do |filename|
                mapped_files[filename] ||= []
                T.must(mapped_files[filename]) << MappingContext.new(glob: glob, feature: feature)
              end
            end
          end

          overlaps = T.let([], T::Array[GlobOverlap])
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

        sig do
          override.params(file: String)
            .returns(T.nilable(FeatureMap::CodeFeatures::Feature))
        end
        def map_file_to_feature(file)
          map_files_to_features([file])[file]
        end

        sig do
          override.params(cache: GlobsToAssignedFeatureMap, files: T::Array[String]).returns(GlobsToAssignedFeatureMap)
        end
        def update_cache(cache, files)
          globs_to_feature(files)
        end

        sig do
          override.params(files: T::Array[String])
            .returns(T::Hash[String, FeatureMap::CodeFeatures::Feature])
        end
        def globs_to_feature(files)
          FeatureMap::CodeFeatures.all.each_with_object({}) do |feature, map|
            FeaturePlugins::Assignment.for(feature).assigned_globs.each do |assigned_glob|
              map[assigned_glob] = feature
            end
          end
        end

        sig { override.void }
        def bust_caches!
          @@map_files_to_features = {} # rubocop:disable Style/ClassVars
        end

        sig { override.returns(String) }
        def description
          'Feature-specific assigned globs'
        end

        sig { override.params(files: T::Array[String], autocorrect: T::Boolean, stage_changes: T::Boolean).returns(T::Array[String]) }
        def validation_errors(files:, autocorrect: true, stage_changes: true)
          overlapping_globs = AssignmentMappers::FeatureGlobs.new.find_overlapping_globs

          errors = T.let([], T::Array[String])

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
