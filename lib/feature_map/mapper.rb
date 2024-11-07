# frozen_string_literal: true

# typed: strict

module FeatureMap
  module Mapper
    extend T::Sig
    extend T::Helpers

    interface!

    class << self
      extend T::Sig

      sig { params(base: T::Class[Mapper]).void }
      def included(base)
        @mappers ||= T.let(@mappers, T.nilable(T::Array[T::Class[Mapper]]))
        @mappers ||= []
        @mappers << base
      end

      sig { returns(T::Array[Mapper]) }
      def all
        (@mappers || []).map(&:new)
      end
    end

    #
    # This should be fast when run with ONE file
    #
    sig do
      abstract.params(file: String)
        .returns(T.nilable(CodeFeatures::Feature))
    end
    def map_file_to_feature(file); end

    #
    # This should be fast when run with MANY files
    #
    sig do
      abstract.params(files: T::Array[String])
        .returns(T::Hash[String, CodeFeatures::Feature])
    end
    def globs_to_feature(files); end

    #
    # This should be fast when run with MANY files
    #
    sig do
      abstract.params(cache: GlobsToAssignedFeatureMap, files: T::Array[String]).returns(GlobsToAssignedFeatureMap)
    end
    def update_cache(cache, files); end

    sig { abstract.returns(String) }
    def description; end

    sig { abstract.void }
    def bust_caches!; end

    sig { returns(Private::GlobCache) }
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
