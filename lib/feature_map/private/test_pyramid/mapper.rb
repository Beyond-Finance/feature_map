module FeatureMap
  module Private
    module TestPyramid
      class Mapper
        class << self
          def examples_by_feature(examples_path, assignments)
            examples_file = File.read(examples_path)
            normalized_assignments = assignments.transform_values { |feature| feature['files'] || [] }

            case examples_path
            when /\.rspec$/
              examples = JSON.parse(examples_file)&.fetch('examples', [])
              TestPyramid::RspecMapper.map_tests_by_assignment(
                examples,
                normalized_assignments
              )
            when /\.jest$/
              examples = JSON.parse(examples_file)&.fetch('testResults', [])
              TestPyramid::JestMapper.map_tests_by_assignment(
                examples,
                normalized_assignments
              )
            else
              raise "Unhandled filetype for unit path: #{examples_path}"
            end
          end
        end
      end
    end
  end
end
