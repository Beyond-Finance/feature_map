# frozen_string_literal: true

# typed: true

module FeatureMap
  module Private
    module AssignmentMappers
      class FeatureDefinitionAssignment
        extend T::Sig
        include Mapper

        @@map_files_to_features = T.let(@map_files_to_features, T.nilable(T::Hash[String, CodeFeatures::Feature])) # rubocop:disable Style/ClassVars
        @@map_files_to_features = {} # rubocop:disable Style/ClassVars

        sig do
          params(files: T::Array[String])
          .returns(T::Hash[String, CodeFeatures::Feature])
        end
        def map_files_to_features(files)
          return @@map_files_to_features if @@map_files_to_features&.keys && @@map_files_to_features.keys.count.positive?

          @@map_files_to_features = CodeFeatures.all.each_with_object({}) do |feature, map| # rubocop:disable Style/ClassVars
            map[feature.config_yml] = feature
          end
        end

        sig do
          override.params(file: String)
            .returns(T.nilable(CodeFeatures::Feature))
        end
        def map_file_to_feature(file)
          return nil if Private.configuration.ignore_feature_definitions

          map_files_to_features([file])[file]
        end

        sig do
          override.params(files: T::Array[String])
            .returns(T::Hash[String, CodeFeatures::Feature])
        end
        def globs_to_feature(files)
          return {} if Private.configuration.ignore_feature_definitions

          CodeFeatures.all.each_with_object({}) do |feature, map|
            map[feature.config_yml] = feature
          end
        end

        sig { override.void }
        def bust_caches!
          @@map_files_to_features = {} # rubocop:disable Style/ClassVars
        end

        sig do
          override.params(cache: GlobsToAssignedFeatureMap, files: T::Array[String]).returns(GlobsToAssignedFeatureMap)
        end
        def update_cache(cache, files)
          globs_to_feature(files)
        end

        sig { override.returns(String) }
        def description
          'Feature definition file assignment'
        end
      end
    end
  end
end
