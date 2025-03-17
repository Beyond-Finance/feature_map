module FeatureMap
  module Private
    module TestPyramid
      class RspecMapper
        class << self
          def map_tests_by_assignment(examples, assignments, path_transform)
            examples_by_file = examples.group_by { |ex| filepath(ex['id']) }

            assignments.each_with_object({}) do |(feature_name, feature), result|
              files = feature['files']&.map { |f| path_transform.call(filepath(f)) } || []
              result[feature_name] = count_example_files(examples_by_file, files)
            end
          end

          private

          def count_example_files(examples_by_file, files)
            files.each_with_object({ count: 0, pending: 0 }) do |file, counts|
              file_examples = examples_by_file[file]
              next unless file_examples

              passed, pending = file_examples.partition { |ex| ex['status'] == 'passed' }
              counts[:count] += passed.size
              counts[:pending] += pending.size
            end
          end

          def filepath(pathlike)
            File
              .join(File.dirname(pathlike), File.basename(pathlike, '.*'))
              .gsub(%r{^\./}, '')
              .gsub(%r{^spec/}, '')
              .gsub(%r{^app/}, '')
          end
        end
      end
    end
  end
end
