# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::TestPyramid::Mapper do
    describe '.examples_by_feature' do
      let(:assignments) do
        {
          'Feature' => { 'files' => ['app/models/user.rb'] }
        }
      end

      # Shared examples for testing different test formats
      shared_examples 'a test mapper' do |file_extension, mapper_class, data_key|
        let(:examples_path) { "tmp/examples.#{file_extension}" }
        let(:examples_data) do
          {
            data_key => test_data
          }
        end

        before do
          write_file(examples_path, examples_data.to_json)
          allow(mapper_class).to receive(:map_tests_by_assignment).and_return('Feature' => { count: 1, pending: 0 })
        end

        it "delegates to #{mapper_class} with normalized assignments" do
          expect(mapper_class).to receive(:map_tests_by_assignment) do |data, normalized_assignments|
            expect(data).to eq(test_data)
            expect(normalized_assignments).to eq('Feature' => ['app/models/user.rb'])

            { 'Feature' => { count: 1, pending: 0 } }
          end

          result = described_class.examples_by_feature(examples_path, assignments)
          expect(result).to eq('Feature' => { count: 1, pending: 0 })
        end
      end

      context 'with RSpec format' do
        let(:test_data) do
          [
            { 'id' => './spec/models/user_spec.rb[1:1]', 'status' => 'passed' }
          ]
        end

        include_examples 'a test mapper', 'rspec', Private::TestPyramid::RspecMapper, 'examples'
      end

      context 'with Jest format' do
        let(:test_data) do
          [
            {
              'name' => '/project/root/src/models/User.test.js',
              'assertionResults' => [{ 'status' => 'passed' }]
            }
          ]
        end

        include_examples 'a test mapper', 'jest', Private::TestPyramid::JestMapper, 'testResults'
      end

      context 'when given an indication to skip processing' do
        it 'returns an empty hash' do
          # NOTE: This file does not need to exist.
          expect(described_class.examples_by_feature('anything.skip', assignments)).to eq({})
        end
      end

      context 'with unsupported format' do
        let(:unknown_path) { 'tmp/examples.unknown' }

        before do
          write_file(unknown_path, 'some content')
        end

        it 'raises an error' do
          expect {
            described_class.examples_by_feature(unknown_path, assignments)
          }.to raise_error(/Unhandled filetype/)
        end
      end

      context 'with nil files in assignments' do
        let(:examples_path) { 'tmp/examples.rspec' }
        let(:assignments_with_nil) do
          {
            'Feature with nil' => { 'files' => nil },
            'Feature with empty' => { 'files' => [] },
            'Feature with files' => { 'files' => ['app/models/user.rb'] }
          }
        end

        before do
          write_file(examples_path, { 'examples' => [] }.to_json)
        end

        it 'handles nil files in assignments gracefully' do
          expect(Private::TestPyramid::RspecMapper).to receive(:map_tests_by_assignment) do |_examples, normalized_assignments|
            expect(normalized_assignments).to eq(
              'Feature with nil' => [],
              'Feature with empty' => [],
              'Feature with files' => ['app/models/user.rb']
            )

            {}
          end

          described_class.examples_by_feature(examples_path, assignments_with_nil)
        end
      end
    end
  end
end
