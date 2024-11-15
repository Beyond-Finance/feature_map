# typed: strict

module FeatureMap
  module Private
    module Validations
      class FeaturesUpToDate
        extend T::Sig
        extend T::Helpers
        include Validator

        sig { override.params(files: T::Array[String], autocorrect: T::Boolean, stage_changes: T::Boolean).returns(T::Array[String]) }
        def validation_errors(files:, autocorrect: true, stage_changes: true)
          return [] if Private.configuration.skip_features_validation

          actual_content_lines = AssignmentsFile.actual_contents_lines
          expected_content_lines = AssignmentsFile.expected_contents_lines

          features_file_up_to_date = actual_content_lines == expected_content_lines
          errors = T.let([], T::Array[String])

          if !features_file_up_to_date
            if autocorrect
              AssignmentsFile.write!
              if stage_changes
                `git add #{AssignmentsFile.path}`
              end
            # If there is no current file or its empty, display a shorter message.
            elsif actual_content_lines == ['']
              errors << <<~FEATURES_FILE_ERROR
                .feature_map/assignments.yml out of date. Run `bin/featuremap validate` to update the .feature_map/assignments.yml file
              FEATURES_FILE_ERROR
            else
              missing_lines = expected_content_lines - actual_content_lines
              extra_lines = actual_content_lines - expected_content_lines

              missing_lines_text = if missing_lines.any?
                                     <<~COMMENT
                                       .feature_map/assignments.yml should contain the following lines, but does not:
                                       #{missing_lines.map { |line| "- \"#{line}\"" }.join("\n")}
                                     COMMENT
                                   end

              extra_lines_text = if extra_lines.any?
                                   <<~COMMENT
                                     .feature_map/assignments.yml should not contain the following lines, but it does:
                                     #{extra_lines.map { |line| "- \"#{line}\"" }.join("\n")}
                                   COMMENT
                                 end

              diff_text = if missing_lines_text && extra_lines_text
                            "#{missing_lines_text}\n#{extra_lines_text}".chomp
                          elsif missing_lines_text
                            missing_lines_text
                          elsif extra_lines_text
                            extra_lines_text
                          else
                            <<~TEXT
                              There may be extra lines, or lines are out of order.
                              You can try to regenerate the .feature_map/assignments.yml file from scratch:
                              1) `rm .feature_map/assignments.yml`
                              2) `bin/featuremap validate`
                            TEXT
                          end

              errors << <<~FEATURES_FILE_ERROR
                .feature_map/assignments.yml out of date. Run `bin/featuremap validate` to update the .feature_map/assignments.yml file

                #{diff_text.chomp}
              FEATURES_FILE_ERROR
            end
          end

          errors
        end
      end
    end
  end
end
