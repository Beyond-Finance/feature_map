# frozen_string_literal: true

module FeatureMap
  module Private
    module AssignmentMappers
      # Calculate, cache, and return a mapping of file names (relative to the root
      # of the repository) to a feature name.
      #
      # Example:
      #
      #   {
      #     'app/models/company.rb' => Feature.find('Onboarding'),
      #     ...
      #   }
      class FileAnnotations
        include Mapper

        # NOTE:  regex 'x' arg ignores whitespace within the _construction_ of the regex.
        #        regex 'm' arg allows the regex to _execute_ on multiline strings.
        SINGLE_LINE_ANNOTATION_PATTERN = /
          \s* # Any amount of whitespace
          (#{Constants::SINGLE_LINE_COMMENT_PATTERNS.join('|')}) # Single line comment start
          \s* # Any amount of whitespace, not including newlines
          @feature\s # We find the feature annotation followed by one space
          (?<feature>.*?$) # A named capture grabs the rest as the feature until the line ends
        /x.freeze

        MULTILINE_ANNOTATION_PATTERN = /
          (?:#{Constants::MULTILINE_COMMENT_START_PATTERNS.join('|')}) # Any comment start
          .*? # Followed by any characters, including newlines, until...
          @feature\s # We find the feature annotation followed by one space
          (?<feature>.*?$) # A named capture grabs the rest as the feature until the line ends
        /xm.freeze

        DESCRIPTION = 'Annotations at the top of file'

        def map_file_to_feature(file)
          file_annotation_based_feature(file)
        end

        def globs_to_feature(files)
          files.each_with_object({}) do |filename_relative_to_root, mapping|
            feature = file_annotation_based_feature(filename_relative_to_root)
            next unless feature

            mapping[filename_relative_to_root] = feature
          end
        end

        def update_cache(cache, files)
          # We map files to nil features so that files whose annotation have been removed will be properly
          # overwritten (i.e. removed) from the cache.
          fileset = Set.new(files)
          updated_cache_for_files = globs_to_feature(files)
          cache.merge!(updated_cache_for_files)

          invalid_files = cache.keys.select do |file|
            # If a file is not tracked, it should be removed from the cache
            !Private.file_tracked?(file) ||
              # If a file no longer has a file annotation (i.e. `globs_to_feature` doesn't map it)
              # it should be removed from the cache
              # We make sure to only apply this to the input files since otherwise `updated_cache_for_files.key?(file)` would always return `false` when files == []
              (fileset.include?(file) && !updated_cache_for_files.key?(file))
          end

          invalid_files.each do |invalid_file|
            cache.delete(invalid_file)
          end

          cache
        end

        def identify_feature_from(lines)
          matched_single_line_feature = lines.join("\n").match(SINGLE_LINE_ANNOTATION_PATTERN)
          matched_multiline_feature = lines.join("\n").match(MULTILINE_ANNOTATION_PATTERN)
          matched_feature = matched_single_line_feature || matched_multiline_feature
          return if matched_feature.nil?

          matched_feature
                     .values_at(:feature)
                     .first
                     .gsub(/#{Constants::MULTILINE_COMMENT_END_PATTERNS.join('|')}/, '')
                     .strip
        rescue ArgumentError => e
          raise unless e.message.include?('invalid byte sequence')
        end

        def file_annotation_based_feature(filename)
          # Not too sure what the following comment means but it was carried over from the code_ownership repo, so
          # I've opted to leave it unchanged in case it is helpful for future engineers:
          #   > If for a directory is named with an ownable extension, we need to skip
          #   > so File.foreach doesn't blow up below. This was needed because Cypress
          #   > screenshots are saved to a folder with the test suite filename.
          return if File.directory?(filename)
          return unless File.file?(filename)

          # The annotation should be on one of the first ten lines.
          # If the annotation isn't in the first ten lines we assume it
          # doesn't exist.

          lines = File.foreach(filename).first(10)
          return if lines.empty?

          feature = identify_feature_from(lines)
          return unless feature

          Private.find_feature!(
            feature,
            filename
          )
        end

        def remove_file_annotation!(filename)
          if file_annotation_based_feature(filename)
            filepath = Pathname.new(filename)
            lines = filepath.read.split("\n")
            new_lines = lines.reject { |line| line[SINGLE_LINE_ANNOTATION_PATTERN] }
            # We explicitly add a final new line since splitting by new line when reading the file lines
            # ignores new lines at the ends of files
            # We also remove leading new lines, since there is after a new line after an annotation
            new_file_contents = "#{new_lines.join("\n")}\n".gsub(/\A\n+/, '')
            filepath.write(new_file_contents)
          end
        end

        def description
          DESCRIPTION
        end

        def bust_caches!; end
      end
    end
  end
end
