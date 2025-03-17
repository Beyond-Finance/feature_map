# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  module Private
    module TestPyramid
      RSpec.describe Mapper do
        let(:unit_path) { 'tmp/unit.rspec' }
        let(:integration_path) { 'tmp/integration.rspec' }
        let(:regression_path) { 'tmp/regression.rspec' }
        let(:regression_assignments_path) { 'regression/.feature_map/assignments.yml' }

        let(:feature_assignments) do
          { 'Bar' => { 'files' => ['app/my_error.rb'] }, 'Foo' => { 'files' => ['app/my_file.rb'] } }
        end
        let(:regression_feature_assignments) do
          { 'features' => { 'Feature B' => { 'files' => ['spec/ui/feature_b_spec.rb'] } } }
        end

        let(:unit_examples) { [{ 'id' => './spec/models/model_a_spec.rb[1:1]', 'status' => 'passed' }] }
        let(:integration_examples) { [{ 'id' => './spec/integration/feature_a_spec.rb[1:1]', 'status' => 'passed' }] }
        let(:regression_examples) { [{ 'id' => './spec/ui/feature_b_spec.rb[1:1]', 'status' => 'passed' }] }

        before do
          create_test_pyramid_artifacts

          # Set up test files with specific examples
          write_file(unit_path, { 'examples' => unit_examples }.to_json)
          write_file(integration_path, { 'examples' => integration_examples }.to_json)
          write_file(regression_path, { 'examples' => regression_examples }.to_json)
          write_file(regression_assignments_path, regression_feature_assignments.to_yaml)

          # Also create the test files for the unsupported format tests
          write_file('unit.unknown', 'some content')
          write_file('integration.unknown', 'some content')
          write_file('regression.unknown', 'some content')

          allow(RspecMapper).to receive(:map_tests_by_assignment).and_return({})
        end

        describe '#unit_by_feature' do
          it 'delegates to RspecMapper with correct parameters and examples' do
            mapper = Mapper.new(unit_path, integration_path, regression_path, regression_assignments_path)

            expect(RspecMapper).to receive(:map_tests_by_assignment) do |examples, assignments, transform|
              expect(examples).to eq(unit_examples)
              expect(assignments).to eq(feature_assignments)
              expect(transform.call('some/path')).to eq('some/path_spec')

              'delegated unit test data'
            end

            expect(mapper.unit_by_feature).to eq('delegated unit test data')
          end

          it 'raises an error for unsupported file types' do
            mapper = Mapper.new('unit.unknown', integration_path, regression_path, regression_assignments_path)
            expect { mapper.unit_by_feature }.to raise_error(/Unhandled filetype/)
          end
        end

        describe '#integration_by_feature' do
          it 'delegates to RspecMapper with correct parameters and examples' do
            mapper = Mapper.new(unit_path, integration_path, regression_path, regression_assignments_path)

            expect(RspecMapper).to receive(:map_tests_by_assignment) do |examples, assignments, transform|
              expect(examples).to eq(integration_examples)
              expect(assignments).to eq(feature_assignments)
              expect(transform.call('some/path')).to eq('some/path')

              'delegated integration test data'
            end

            expect(mapper.integration_by_feature).to eq('delegated integration test data')
          end

          it 'raises an error for unsupported file types' do
            mapper = Mapper.new(unit_path, 'integration.unknown', regression_path, regression_assignments_path)
            expect { mapper.integration_by_feature }.to raise_error(/Unhandled filetype/)
          end
        end

        describe '#regression_by_feature' do
          it 'delegates to RspecMapper with correct parameters and examples' do
            mapper = Mapper.new(unit_path, integration_path, regression_path, regression_assignments_path)

            expect(RspecMapper).to receive(:map_tests_by_assignment) do |examples, assignments, transform|
              expect(examples).to eq(regression_examples)
              expect(assignments).to eq(regression_feature_assignments['features'])
              expect(transform.call('some/path')).to eq('some/path')

              'delegated regression test data'
            end

            expect(mapper.regression_by_feature).to eq('delegated regression test data')
          end

          it 'returns an empty hash when regression_path is nil' do
            mapper = Mapper.new(unit_path, integration_path, nil, regression_assignments_path)
            expect(mapper.regression_by_feature).to eq({})
            expect(RspecMapper).not_to receive(:map_tests_by_assignment)
          end

          it 'uses default assignments when regression_assignments_path is nil' do
            mapper = Mapper.new(unit_path, integration_path, regression_path, nil)

            expect(RspecMapper).to receive(:map_tests_by_assignment) do |examples, assignments, transform|
              expect(examples).to eq(regression_examples)
              expect(assignments).to eq(feature_assignments)
              expect(transform.call('some/path')).to eq('some/path')
            end

            mapper.regression_by_feature
          end

          it 'raises an error for unsupported file types' do
            mapper = Mapper.new(unit_path, integration_path, 'regression.unknown', regression_assignments_path)
            expect { mapper.regression_by_feature }.to raise_error(/Unhandled filetype/)
          end
        end
      end
    end
  end
end
