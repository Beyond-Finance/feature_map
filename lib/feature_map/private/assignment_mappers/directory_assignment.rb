# frozen_string_literal: true

module FeatureMap
  module Private
    module AssignmentMappers
      class DirectoryAssignment
        include Mapper

        FEATURE_DIRECTORY_ASSIGNMENT_FILE_NAME = '.feature'

        @@directory_cache = {} # rubocop:disable Style/ClassVars

        def map_file_to_feature(file)
          map_file_to_relevant_feature(file)
        end

        def update_cache(cache, files)
          globs_to_feature(files)
        end

        #
        # Directory assignment ignores the passed in files when generating feature assignment lines.
        # This is because directory assignment knows that the fastest way to find features for directory based assignment
        # is to simply iterate over the directories and grab the feature, rather than iterating over each file just to get what directory it is in
        # In theory this means that we may generate feature lines that cover files that are not in the passed in argument,
        # but in practice this is not of consequence because in reality we never really want to generate feature assignments for only a
        # subset of files, but rather we want feature assignments for all files.
        #
        def globs_to_feature(files)
          Pathname
            .glob(File.join('**/', FEATURE_DIRECTORY_ASSIGNMENT_FILE_NAME))
            .map(&:cleanpath)
            .each_with_object({}) do |pathname, res|
              feature = feature_for_directory_assignment_file(pathname)
              glob = glob_for_directory_assignment_file(pathname)
              res[glob] = feature
            end
        end

        def description
          'Feature Assigned in .feature'
        end

        def bust_caches!
          @@directory_cache = {} # rubocop:disable Style/ClassVars
        end

        private

        def feature_for_directory_assignment_file(file)
          raw_feature_value = File.foreach(file).first.strip

          Private.find_feature!(
            raw_feature_value,
            file.to_s
          )
        end

        # Takes a file and finds the relevant `.feature` file by walking up the directory
        # structure. Example, given `a/b/c.rb`, this looks for `a/b/.feature`, `a/.feature`,
        # and `.feature` in that order, stopping at the first file to actually exist.
        # If the provided file is a directory, it will look for `.feature` in that directory and then upwards.
        # We do additional caching so that we don't have to check for file existence every time.
        def map_file_to_relevant_feature(file)
          file_path = Pathname.new(file)
          feature = nil

          if File.directory?(file)
            feature = get_feature_from_assignment_file_within_directory(file_path)
            return feature unless feature.nil?
          end

          path_components = file_path.each_filename.to_a
          if file_path.absolute?
            path_components = ['/', *path_components]
          end

          (path_components.length - 1).downto(0).each do |i|
            feature = get_feature_from_assignment_file_within_directory(
               Pathname.new(File.join(*path_components[0...i]))
             )
            return feature unless feature.nil?
          end

          feature
        end

        def get_feature_from_assignment_file_within_directory(directory)
          potential_directory_assignment_file = directory.join(FEATURE_DIRECTORY_ASSIGNMENT_FILE_NAME)

          potential_directory_assignment_file_name = potential_directory_assignment_file.to_s

          feature = nil
          if @@directory_cache.key?(potential_directory_assignment_file_name)
            feature = @@directory_cache[potential_directory_assignment_file_name]
          elsif potential_directory_assignment_file.exist?
            feature = feature_for_directory_assignment_file(potential_directory_assignment_file)

            @@directory_cache[potential_directory_assignment_file_name] = feature
          else
            @@directory_cache[potential_directory_assignment_file_name] = nil
          end

          feature
        end

        def glob_for_directory_assignment_file(file)
          unescaped = file.dirname.cleanpath.join('**/**').to_s

          # Globs can contain certain regex characters, like "[" and "]".
          # However, when we are generating a glob from a .feature file, we
          # need to escape bracket characters and interpret them literally.
          # Otherwise the resulting glob will not actually match the directory
          # containing the .feature file.
          #
          # Example
          # file: "/some/[dir]/.feature"
          # unescaped: "/some/[dir]/**/**"
          # matches: "/some/d/file"
          # matches: "/some/i/file"
          # matches: "/some/r/file"
          # does not match!: "/some/[dir]/file"
          unescaped.gsub(/[\[\]]/) { |x| "\\#{x}" }
        end
      end
    end
  end
end
