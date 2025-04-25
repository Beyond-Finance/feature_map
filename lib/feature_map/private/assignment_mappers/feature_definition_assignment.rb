# frozen_string_literal: true

module FeatureMap
  module Private
    module AssignmentMappers
      class FeatureDefinitionAssignment
        include Mapper

        @@map_files_to_features = @map_files_to_features # rubocop:disable Style/ClassVars
        @@map_files_to_features = {} # rubocop:disable Style/ClassVars

        def map_files_to_features(files)
          return @@map_files_to_features if @@map_files_to_features&.any?

          @@map_files_to_features = CodeFeatures.all.each_with_object({}) do |feature, map| # rubocop:disable Style/ClassVars
            # NOTE:  The FeatureDefinitionAssignment naively assumes that all
            #        features will have a definition yaml file.  This comes from
            #        the CodeOwnership implementation which does require these
            #        files to exist.  This is not true in repositories using the
            #        feature_definitions.csv style of feature definition.
            next if feature.config_yml.nil?

            map[feature.config_yml] = feature
          end
        end

        def map_file_to_feature(file)
          return nil if Private.configuration.ignore_feature_definitions

          map_files_to_features([file])[file]
        end

        def globs_to_feature(files)
          return {} if Private.configuration.ignore_feature_definitions

          CodeFeatures.all.each_with_object({}) do |feature, map|
            # NOTE:  The FeatureDefinitionAssignment naively assumes that all
            #        features will have a definition yaml file.  This comes from
            #        the CodeOwnership implementation which does require these
            #        files to exist.  This is not true in repositories using the
            #        feature_definitions.csv style of feature definition.
            next if feature.config_yml.nil?

            map[feature.config_yml] = feature
          end
        end

        def bust_caches!
          @@map_files_to_features = {} # rubocop:disable Style/ClassVars
        end

        def update_cache(cache, files)
          globs_to_feature(files)
        end

        def description
          'Feature definition file assignment'
        end
      end
    end
  end
end
