module FeatureMap
  module Private
    module TestPyramid
      class JestMapper
        class << self
          def map_tests_by_assignment(test_suites, assignments)
            # Transform test suites into a hash of filepath => assertion results
            tests_by_path = test_suites.each_with_object({}) do |suite, result|
              result[filepath(suite['name'])] = suite['assertionResults']
            end

            assignments.each_with_object({}) do |(feature_name, feature), result|
              feature_files = feature['files'] || []
              counts = count_tests_for_feature(tests_by_path, feature_files)
              result[feature_name] = counts
            end
          end

          private

          def count_tests_for_feature(tests_by_path, feature_files)
            feature_files.each_with_object({ count: 0, pending: 0 }) do |file, counts|
              file_path = filepath(file)
              assertions = tests_by_path[file_path]
              next unless assertions

              passed, pending = assertions.partition { |assertion| !%w[pending skipped todo].include?(assertion['status']) }
              counts[:count] += passed.size
              counts[:pending] += pending.size
            end
          end

          def filepath(pathlike)
            # Get the base directory of the script execution
            project_root = Dir.pwd
            path = File.join(File.dirname(pathlike), File.basename(pathlike, '.*'))

            # Strip absolute path prefix, keeping path relative to the project root
            path.gsub("#{project_root}/", '')
          end
        end
      end
    end
  end
end
