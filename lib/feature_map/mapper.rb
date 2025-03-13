# @feature Core Library
# frozen_string_literal: true

module FeatureMap
  module Mapper
    class << self
      def included(base)
        @mappers ||= []
        @mappers << base
      end

      def all
        (@mappers || []).map(&:new)
      end
    end

    #
    # This should be fast when run with ONE file
    #
    def map_file_to_feature(file); end

    #
    # This should be fast when run with MANY files
    #
    def globs_to_feature(files); end

    #
    # This should be fast when run with MANY files
    #
    def update_cache(cache, files); end

    def description; end

    def bust_caches!; end

    def self.to_glob_cache
      glob_to_feature_map_by_mapper_description = {}

      Mapper.all.each do |mapper|
        mapped_files = mapper.globs_to_feature(Private.tracked_files)
        glob_to_feature_map_by_mapper_description[mapper.description] ||= {}

        mapped_files.each do |glob, feature|
          next if feature.nil?

          glob_to_feature_map_by_mapper_description.fetch(mapper.description)[glob] = feature
        end
      end

      Private::GlobCache.new(glob_to_feature_map_by_mapper_description)
    end
  end
end
