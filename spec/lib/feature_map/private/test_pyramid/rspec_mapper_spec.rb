# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::TestPyramid::RspecMapper do
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
          'User Management' => [
            'app/models/user.rb',
            'app/controllers/users_controller.rb'
          ],
          'Authentication' => [
            'app/services/auth_service.rb'
          ],
          'Empty Feature' => [
            'app/models/unused_model.rb'
          ]
        }
      end

      it 'maps tests to their respective features' do
        result = described_class.map_tests_by_assignment(examples, assignments)

        expect(result).to eq(
          'User Management' => { count: 3, pending: 1 },
          'Authentication' => { count: 0, pending: 1 },
          'Empty Feature' => { count: 0, pending: 0 }
        )
      end

      it 'handles empty examples gracefully' do
        result = described_class.map_tests_by_assignment([], assignments)

        expect(result).to eq(
          'User Management' => { count: 0, pending: 0 },
          'Authentication' => { count: 0, pending: 0 },
          'Empty Feature' => { count: 0, pending: 0 }
        )
      end

      it 'handles empty assignments gracefully' do
        result = described_class.map_tests_by_assignment(examples, {})
        expect(result).to eq({})
      end

      it 'handles variations in file path formats' do
        # Create examples with different path formats
        mixed_examples = [
          { 'id' => './spec/models/product_spec.rb[1:1]', 'status' => 'passed' },
          { 'id' => 'spec/services/product_service_spec.rb[1:1]', 'status' => 'passed' }
        ]

        # Create assignments with mixed path formats
        mixed_assignments = {
          'Product Feature' => [
            'app/models/product.rb',
            'services/product_service.rb' # No app/ prefix
          ]
        }

        result = described_class.map_tests_by_assignment(mixed_examples, mixed_assignments)
        expect(result).to eq('Product Feature' => { count: 2, pending: 0 })
      end

      context 'with path normalization' do
        it 'maps files with different path formats to the same feature' do
          examples = [
            { 'id' => './spec/models/user_spec.rb[1:1]', 'status' => 'passed' },
            { 'id' => 'spec/models/account_spec.rb[1:1]', 'status' => 'passed' }
          ]

          assignments = {
            'User Feature' => [
              'app/models/user.rb'
            ],
            'Account Feature' => [
              'models/account.rb' # No app/ prefix
            ]
          }

          result = described_class.map_tests_by_assignment(examples, assignments)

          # Both should match despite different path formats
          expect(result).to eq(
            'User Feature' => { count: 1, pending: 0 },
            'Account Feature' => { count: 1, pending: 0 }
          )
        end

        it 'correctly matches spec files to app files with different formats' do
          varied_examples = [
            { 'id' => './spec/models/user_spec.rb[1:1]', 'status' => 'passed' },
            { 'id' => 'spec/controllers/users_controller_spec.rb[1:1]', 'status' => 'passed' }
          ]

          varied_assignments = {
            'User Model' => ['models/user.rb'], # No app/ prefix
            'Users Controller' => ['app/controllers/users_controller.rb'] # With app/ prefix
          }

          result = described_class.map_tests_by_assignment(varied_examples, varied_assignments)

          expect(result).to eq(
            'User Model' => { count: 1, pending: 0 },
            'Users Controller' => { count: 1, pending: 0 }
          )
        end
      end
    end
  end
end
