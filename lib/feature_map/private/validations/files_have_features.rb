require 'code_ownership'

module FeatureMap
  module Private
    module Validations
      class FilesHaveFeatures
        include Validator

        def validation_errors(files:, autocorrect: true, stage_changes: true)
          cache = Private.glob_cache
          file_mappings = cache.mapper_descriptions_that_map_files(files)
          files_not_mapped_at_all = file_mappings.select do |_file, mapper_descriptions|
            mapper_descriptions.none?
          end

          errors = []

          # When a set of teams are configured that require assignments, ignore any files NOT
          # assigned to one of these teams.
          unless Private.configuration.require_assignment_for_teams.nil?
            files_not_mapped_at_all.filter! do |file, _mappers|
              file_team = CodeOwnership.for_file(file)
              file_team && Private.configuration.require_assignment_for_teams.include?(file_team.name)
            end
          end

          if files_not_mapped_at_all.any?
            errors << <<~MSG
              Some files are missing a feature assignment:

              #{files_not_mapped_at_all.map { |file, _mappers| "- #{file}" }.join("\n")}
            MSG
          end

          errors
        end
      end
    end
  end
end
