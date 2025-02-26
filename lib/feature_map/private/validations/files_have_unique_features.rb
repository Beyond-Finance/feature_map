module FeatureMap
  module Private
    module Validations
      class FilesHaveUniqueFeatures
        include Validator

        def validation_errors(files:, autocorrect: true, stage_changes: true)
          cache = Private.glob_cache
          file_mappings = cache.mapper_descriptions_that_map_files(files)
          files_mapped_by_multiple_mappers = file_mappings.select do |_file, mapper_descriptions|
            mapper_descriptions.count > 1
          end

          errors = []

          if files_mapped_by_multiple_mappers.any?
            errors << <<~MSG
              Feature assignment should only be defined for each file in one way. The following files have had features assigned in multiple ways.

              #{files_mapped_by_multiple_mappers.map { |file, descriptions| "- #{file} (#{descriptions.to_a.join(', ')})" }.join("\n")}
            MSG
          end

          errors
        end
      end
    end
  end
end
