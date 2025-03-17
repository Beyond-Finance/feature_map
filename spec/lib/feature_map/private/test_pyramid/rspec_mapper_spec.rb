# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  module Private
    module TestPyramid
      RSpec.describe RspecMapper do
        describe '.map_tests_by_assignment' do
          let(:examples) do
            [
              { 'id' => './spec/models/user_spec.rb[1:1]', 'status' => 'passed' },
              { 'id' => './spec/models/user_spec.rb[1:2]', 'status' => 'pending' },
              { 'id' => './spec/controllers/users_controller_spec.rb[1:1]', 'status' => 'passed' },
              { 'id' => './spec/controllers/users_controller_spec.rb[1:2]', 'status' => 'passed' },
              { 'id' => './spec/services/auth_service_spec.rb[1:1]', 'status' => 'pending' }
            ]
          end

          let(:assignments) do
            {
              'User Management' => {
                'files' => [
                  'app/models/user.rb',
                  'app/controllers/users_controller.rb'
                ]
              },
              'Authentication' => {
                'files' => [
                  'app/services/auth_service.rb'
                ]
              },
              'Empty Feature' => {
                'files' => [
                  'app/models/unused_model.rb'
                ]
              }
            }
          end

          let(:path_transform) { ->(path) { "#{path}_spec" } }

          it 'maps tests to their respective features' do
            result = described_class.map_tests_by_assignment(examples, assignments, path_transform)

            expect(result).to eq(
              'User Management' => { count: 3, pending: 1 },
              'Authentication' => { count: 0, pending: 1 },
              'Empty Feature' => { count: 0, pending: 0 }
            )
          end

          it 'handles empty examples gracefully' do
            result = described_class.map_tests_by_assignment([], assignments, path_transform)

            expect(result).to eq(
              'User Management' => { count: 0, pending: 0 },
              'Authentication' => { count: 0, pending: 0 },
              'Empty Feature' => { count: 0, pending: 0 }
            )
          end

          it 'handles empty assignments gracefully' do
            result = described_class.map_tests_by_assignment(examples, {}, path_transform)
            expect(result).to eq({})
          end

          it 'handles features with nil files' do
            # We'll fix the implementation to handle nil files properly
            assignments_with_nil = {
              'No Files Feature' => { 'files' => nil }
            }

            # The implementation should handle nil files by treating them as an empty array
            result = described_class.map_tests_by_assignment(examples, assignments_with_nil, path_transform)
            expect(result).to eq('No Files Feature' => { count: 0, pending: 0 })
          end

          it 'handles features with empty files array' do
            assignments_with_empty = {
              'Empty Files Feature' => { 'files' => [] }
            }

            result = described_class.map_tests_by_assignment(examples, assignments_with_empty, path_transform)
            expect(result).to eq('Empty Files Feature' => { count: 0, pending: 0 })
          end

          it 'processes files that don\'t match any examples' do
            assignments_with_nonexistent = {
              'Nonexistent Files' => {
                'files' => ['app/models/nonexistent.rb']
              }
            }

            result = described_class.map_tests_by_assignment(examples, assignments_with_nonexistent, path_transform)
            expect(result).to eq('Nonexistent Files' => { count: 0, pending: 0 })
          end

          context 'with path transformation' do
            it 'applies the path transform function correctly' do
              # Create a path transform that adds a custom suffix
              suffix_transform = ->(path) { "#{path}_customtest" }

              # Create a custom example that will match after transformation
              custom_examples = [
                { 'id' => './spec/models/user_customtest.rb[1:1]', 'status' => 'passed' }
              ]

              # Create an assignment that will match after transformation
              custom_assignment = {
                'Custom Feature' => {
                  'files' => ['app/models/user.rb']
                }
              }

              result = described_class.map_tests_by_assignment(
                custom_examples,
                custom_assignment,
                suffix_transform
              )

              # After transformation, 'app/models/user.rb' becomes 'models/user_customtest'
              # which should match with the example 'spec/models/user_customtest.rb'
              expect(result).to eq('Custom Feature' => { count: 1, pending: 0 })
            end
          end
        end
      end
    end
  end
end
