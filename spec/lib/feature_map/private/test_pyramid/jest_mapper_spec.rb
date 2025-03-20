# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::TestPyramid::JestMapper do
    describe '.map_tests_by_assignment' do
      before do
        # Stub Dir.pwd to return a consistent path for testing
        allow(Dir).to receive(:pwd).and_return('/project/root')
      end

      let(:test_suites) do
        [
          {
            'name' => '/project/root/src/models/User.test.js',
            'assertionResults' => [
              { 'status' => 'passed' },
              { 'status' => 'passed' },
              { 'status' => 'pending' }
            ]
          },
          {
            'name' => '/project/root/src/controllers/UserController.test.js',
            'assertionResults' => [
              { 'status' => 'passed' },
              { 'status' => 'skipped' }
            ]
          },
          {
            'name' => '/project/root/src/services/AuthService.test.js',
            'assertionResults' => [
              { 'status' => 'todo' },
              { 'status' => 'passed' }
            ]
          }
        ]
      end

      let(:assignments) do
        {
          'User Management' => [
            'src/models/User.js',
            'src/controllers/UserController.js',
            'src/models/User.test.js', # Test file included
            'src/controllers/UserController.test.js' # Test file included
          ],
          'Authentication' => [
            'src/services/AuthService.js',
            'src/services/AuthService.test.js'    # Test file included
          ],
          'Empty Feature' => [
            'src/models/UnusedModel.js',
            'src/models/UnusedModel.test.js'      # Test file included (nonexistent)
          ]
        }
      end

      it 'maps tests to their respective features' do
        result = described_class.map_tests_by_assignment(test_suites, assignments)

        expect(result).to eq(
          'User Management' => { count: 3, pending: 2 },
          'Authentication' => { count: 1, pending: 1 },
          'Empty Feature' => { count: 0, pending: 0 }
        )
      end

      it 'handles empty test suites gracefully' do
        result = described_class.map_tests_by_assignment([], assignments)

        expect(result).to eq(
          'User Management' => { count: 0, pending: 0 },
          'Authentication' => { count: 0, pending: 0 },
          'Empty Feature' => { count: 0, pending: 0 }
        )
      end

      it 'handles empty assignments gracefully' do
        result = described_class.map_tests_by_assignment(test_suites, {})
        expect(result).to eq({})
      end

      it 'counts pending, skipped, and todo statuses as pending' do
        pending_suites = [
          {
            'name' => '/project/root/src/services/PendingService.test.js',
            'assertionResults' => [
              { 'status' => 'pending' },
              { 'status' => 'skipped' },
              { 'status' => 'todo' }
            ]
          }
        ]

        pending_assignments = {
          'Pending Feature' => [
            'src/services/PendingService.js',
            'src/services/PendingService.test.js'
          ]
        }

        result = described_class.map_tests_by_assignment(pending_suites, pending_assignments)
        expect(result).to eq('Pending Feature' => { count: 0, pending: 3 })
      end

      it 'handles variations in file path formats' do
        mixed_suites = [
          {
            'name' => '/project/root/src/components/Button.test.js',
            'assertionResults' => [{ 'status' => 'passed' }]
          },
          {
            'name' => '/project/root/src/components/Form.test.jsx',
            'assertionResults' => [{ 'status' => 'passed' }]
          }
        ]

        mixed_assignments = {
          'UI Components' => [
            'src/components/Button.js',
            'src/components/Form.jsx',
            'src/components/Button.test.js',
            'src/components/Form.test.jsx'
          ]
        }

        result = described_class.map_tests_by_assignment(mixed_suites, mixed_assignments)
        expect(result).to eq('UI Components' => { count: 2, pending: 0 })
      end

      it 'matches test files to their implementation correctly' do
        extension_suites = [
          {
            'name' => '/project/root/src/utils/helpers.test.ts',
            'assertionResults' => [{ 'status' => 'passed' }]
          }
        ]

        extension_assignments = {
          'Utils' => [
            'src/utils/helpers.js', # Different extension
            'src/utils/helpers.test.ts'
          ]
        }

        result = described_class.map_tests_by_assignment(extension_suites, extension_assignments)
        expect(result).to eq('Utils' => { count: 1, pending: 0 })
      end
    end
  end
end
