module FeatureMap
  module Private
    module TestPyramid
      class RspecMapper
        class << self
          def map_tests_by_assignment(examples, assignments)
            normalized_assignments = transform_assignments(assignments)
            examples_by_file = examples.group_by { |ex| filepath(ex['id']) }

            normalized_assignments.transform_values do |files|
              count_example_files(examples_by_file, files)
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

          # NOTE:  We normalize paths to remove the app/ and spec/ prefix,
          #        as well as the _spec suffix.  This allows for spec files to
          #        be mapped to feature-assigned app-paths such that the specs
          #        do not need to be directly assigned to features.  It still
          #        works if they are directly assigned to features, too.
          def filepath(pathlike)
            File
              .join(File.dirname(pathlike), File.basename(pathlike, '.*'))
              .gsub(%r{^\./}, '')
              .gsub(%r{^spec/}, '')
              .gsub(%r{^app/}, '')
              .gsub(/_spec$/, '')
          end

          def transform_assignments(assignments)
            assignments.transform_values do |files|
              [
                *files,
                files.map { |f| filepath(f) }
              ].flatten
            end
          end
        end
      end
    end
  end
end
