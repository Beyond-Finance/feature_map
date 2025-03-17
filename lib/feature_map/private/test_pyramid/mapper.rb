module FeatureMap
  module Private
    module TestPyramid
      class Mapper
        attr_reader :default_assignments, :unit_path, :integration_path, :regression_path, :regression_assignments_path

        def initialize(unit_path, integration_path, regression_path, regression_assignments_path)
          @default_assignments = AssignmentsFile.load_features!
          @unit_path = unit_path
          @integration_path = integration_path
          @regression_path = regression_path
          @regression_assignments_path = regression_assignments_path
        end

        def unit_by_feature
          unit_file = File.read(unit_path)

          case unit_path
          when /\.rspec$/
            unit_examples = JSON.parse(unit_file)&.fetch('examples')
            TestPyramid::RspecMapper.map_tests_by_assignment(
              unit_examples,
              default_assignments,
              ->(path) { "#{path}_spec" }
            )
          else
            raise "Unhandled filetype for unit path: #{unit_path}"
          end
        end

        def integration_by_feature
          integration_file = File.read(integration_path)

          case integration_path
          when /\.rspec$/
            integration_examples = JSON.parse(integration_file)&.fetch('examples')
            TestPyramid::RspecMapper.map_tests_by_assignment(
              integration_examples,
              default_assignments,
              ->(path) { path }
            )
          else
            raise "Unhandled filetype for integration path: #{integration_path}"
          end
        end

        def regression_by_feature
          return {} unless regression_path

          regression_file = File.read(regression_path)
          regression_assignments = regression_assignments_path ? YAML.load_file(regression_assignments_path)&.fetch('features') : default_assignments

          case regression_path
          when /\.rspec$/
            regression_examples = JSON.parse(regression_file)&.fetch('examples')
            TestPyramid::RspecMapper.map_tests_by_assignment(
              regression_examples,
              regression_assignments,
              ->(path) { path }
            )
          else
            raise "Unhandled filetype for regression path: #{regression_path}"
          end
        end
      end
    end
  end
end
