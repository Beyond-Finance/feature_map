# typed: strict
# frozen_string_literal: true

module FeatureMap
  module Private
    #
    # This class is responsible for turning FeatureMap directives (e.g. annotations, directory assignments, etc)
    # into a FEAUTERS.yml file, that can be used as an input to a variety of engineering team utilities (e.g.
    # PR/release announcements, documentation generation, etc).
    #
    class FeaturesFile
      extend T::Sig

      FILES_KEY = 'files'
      FILE_FEATURE_KEY = 'feature'
      FILE_MAPPER_KEY = 'mapper'
      FEATURES_KEY = 'features'
      FEATURE_FILES_KEY = 'files'

      FeatureName = T.type_alias { String }
      FilePath = T.type_alias { String }
      MapperDescription = T.type_alias { String }

      FileDetails = T.type_alias do
        T::Hash[
          String,
          T.any(FeatureName, MapperDescription)
        ]
      end

      FilesContent = T.type_alias do
        T::Hash[
          FilePath,
          FileDetails
        ]
      end

      FileList = T.type_alias { T::Array[String] }

      FeatureDetails = T.type_alias do
        T::Hash[
          String,
          FileList
        ]
      end

      FeaturesContent = T.type_alias do
        T::Hash[
          FeatureName,
          FeatureDetails
        ]
      end

      sig { returns(T::Array[String]) }
      def self.actual_contents_lines
        if path.exist?
          content = path.read
          lines = path.read.split("\n")
          if content.end_with?("\n")
            lines << ''
          end
          lines
        else
          ['']
        end
      end

      sig { returns(T::Array[T.nilable(String)]) }
      def self.expected_contents_lines
        cache = Private.glob_cache.raw_cache_contents

        header = <<~HEADER
          # STOP! - DO NOT EDIT THIS FILE MANUALLY
          # This file was automatically generated by "bin/featuremap validate". The next time this file
          # is generated any changes will be lost. For more details:
          # https://github.com/Beyond-Finance/feature_map
        HEADER

        files_content = T.let({}, FilesContent)
        features_content = T.let({}, FeaturesContent)

        cache.each do |mapper_description, assignment_map_cache|
          assignment_map_cache = assignment_map_cache.sort_by do |glob, _feature|
            glob
          end

          assignment_map_cache.to_h.each do |path, feature|
            files_content[path] = T.let({ FILE_FEATURE_KEY => feature.name, FILE_MAPPER_KEY => mapper_description }, FileDetails)
            features_content[feature.name] ||= T.let({}, FeatureDetails)
            T.must(features_content[feature.name])[FEATURE_FILES_KEY] ||= T.let([], FileList)
            T.must(T.must(features_content[feature.name])[FEATURE_FILES_KEY]) << path
          end
        end

        # Calculate total lines of code for each feature
        features_content.each_value do |feature_content|
          expanded_files = T.must(feature_content[FEATURE_FILES_KEY]).flat_map { |file| Dir.glob(file) }.reject { |path| File.directory?(path) }
          total_lines = expanded_files.sum { |file| count_lines_of_code(file) }
          feature_content['total_lines'] = total_lines
          T.must(feature_content[FEATURE_FILES_KEY]).sort! if feature_content[FEATURE_FILES_KEY]
        end

        [
          *header.split("\n"),
          '', # For line between header and files_assignment_lines
          *{ FILES_KEY => files_content, FEATURES_KEY => features_content }.to_yaml.split("\n"),
          '' # For end-of-file newline
        ]
      end

      def self.count_lines_of_code(file)
        File.read(file).lines.count
      end

      sig { void }
      def self.write!
        FileUtils.mkdir_p(path.dirname) if !path.dirname.exist?
        path.write(expected_contents_lines.join("\n"))
      end

      sig { returns(Pathname) }
      def self.path
        Pathname.pwd.join('FEATURES.yml')
      end

      sig { params(files: T::Array[String]).void }
      def self.update_cache!(files)
        cache = Private.glob_cache
        # Each mapper returns a new copy of the cache subset related to that mapper,
        # which is then stored back into the cache.
        Mapper.all.each do |mapper|
          existing_cache = cache.raw_cache_contents.fetch(mapper.description, {})
          updated_cache = mapper.update_cache(existing_cache, files)
          cache.raw_cache_contents[mapper.description] = updated_cache
        end
      end

      sig { returns(T::Boolean) }
      def self.use_features_cache?
        FeaturesFile.path.exist? && !Private.configuration.skip_features_validation
      end

      sig { returns(GlobCache) }
      def self.to_glob_cache
        raw_cache_contents = T.let({}, GlobCache::CacheShape)
        features_by_name = CodeFeatures.all.each_with_object({}) do |feature, map|
          map[feature.name] = feature
        end
        mapper_descriptions = Set.new(Mapper.all.map(&:description))

        features_file_content = YAML.load_file(path)
        features_file_content[FILES_KEY]&.each do |file_path, file_assignment|
          next if file_assignment.nil?
          next if file_assignment[FILE_FEATURE_KEY].nil? || features_by_name[file_assignment[FILE_FEATURE_KEY]].nil?
          next if file_assignment[FILE_MAPPER_KEY].nil? || !mapper_descriptions.include?(file_assignment[FILE_MAPPER_KEY])

          raw_cache_contents[file_assignment[FILE_MAPPER_KEY]] ||= {}
          raw_cache_contents.fetch(file_assignment[FILE_MAPPER_KEY])[file_path] = features_by_name[file_assignment[FILE_FEATURE_KEY]]
        end

        GlobCache.new(raw_cache_contents)
      end
    end
  end
end
