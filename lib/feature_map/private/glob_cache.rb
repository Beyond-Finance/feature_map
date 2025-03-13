# @feature Assignment Mapping
# frozen_string_literal: true

module FeatureMap
  module Private
    class GlobCache
      def initialize(raw_cache_contents)
        @raw_cache_contents = raw_cache_contents
      end

      def raw_cache_contents
        @raw_cache_contents
      end

      def mapper_descriptions_that_map_files(files)
        files_by_mappers = files.to_h { |f| [f, Set.new([])] }

        files_by_mappers_via_expanded_cache.each do |file, mappers|
          mappers.each do |mapper|
            files_by_mappers[file] << mapper if files_by_mappers[file]
          end
        end

        files_by_mappers
      end

      private

      def expanded_cache
        @expanded_cache ||= begin
          expanded_cache = {}
          @raw_cache_contents.each do |mapper_description, globs_by_feature|
            expanded_cache[mapper_description] = FeatureAssigner.assign_features(globs_by_feature)
          end
          expanded_cache
        end
      end

      def files_by_mappers_via_expanded_cache
        @files_by_mappers_via_expanded_cache ||= begin
          files_by_mappers = {}
          expanded_cache.each do |mapper_description, file_by_feature|
            file_by_feature.each_key do |file|
              files_by_mappers[file] ||= Set.new([])
              files_by_mappers.fetch(file) << mapper_description
            end
          end

          files_by_mappers
        end
      end
    end
  end
end
