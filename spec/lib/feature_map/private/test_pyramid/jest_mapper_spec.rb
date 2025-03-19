# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  module Private
    module TestPyramid
      RSpec.describe JestMapper do
        describe '.map_tests_by_assignment' do
          # This test will use a mock for Dir.pwd since it's critical to the filepath normalization
          before do
            allow(Dir).to receive(:pwd).and_return('/Users/dev/project')
          end

          let(:test_suites) do
            [
              {
                'name' => '/Users/dev/project/src/components/Users/User.test.js',
                'assertionResults' => [
                  { 'status' => 'passed' },
                  { 'status' => 'passed' },
                  { 'status' => 'pending' }
                ]
              },
              {
                'name' => '/Users/dev/project/src/components/Auth/Login.test.js',
                'assertionResults' => [
                  { 'status' => 'passed' },
                  { 'status' => 'failed' }
                ]
              },
              {
                'name' => '/Users/dev/project/src/services/AuthService.test.js',
                'assertionResults' => [
                  { 'status' => 'skipped' },
                  { 'status' => 'todo' }
                ]
              }
            ]
          end

          let(:assignments) do
            {
              'User Management' => {
                'files' => [
                  'src/components/Users/User.test.js'
                ]
              },
              'Authentication' => {
                'files' => [
                  'src/components/Auth/Login.test.js',
                  'src/services/AuthService.test.js'
                ]
              },
              'Empty Feature' => {
                'files' => [
                  'src/components/Unused/Component.test.js'
                ]
              }
            }
          end

          it 'maps tests to their respective features' do
            result = described_class.map_tests_by_assignment(test_suites, assignments)

            expect(result).to eq(
              'User Management' => { count: 2, pending: 1 },
              'Authentication' => { count: 2, pending: 2 },
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

          it 'handles test paths with different formats' do
            mixed_path_test_suites = [
              # Absolute path
              {
                'name' => '/Users/dev/project/src/components/Button.test.js',
                'assertionResults' => [{ 'status' => 'passed' }]
              },
              # Relative path
              {
                'name' => 'src/components/Input.test.js',
                'assertionResults' => [{ 'status' => 'passed' }]
              }
            ]

            mixed_path_assignments = {
              'Components' => {
                'files' => [
                  'src/components/Button.test.js',
                  'src/components/Input.test.js'
                ]
              }
            }

            result = described_class.map_tests_by_assignment(mixed_path_test_suites, mixed_path_assignments)
            expect(result).to eq('Components' => { count: 2, pending: 0 })
          end

          it 'handles empty assignments gracefully' do
            result = described_class.map_tests_by_assignment(test_suites, {})
            expect(result).to eq({})
          end

          it 'handles features with nil files' do
            nil_files_assignments = {
              'No Files Feature' => { 'files' => nil }
            }

            result = described_class.map_tests_by_assignment(test_suites, nil_files_assignments)
            expect(result).to eq('No Files Feature' => { count: 0, pending: 0 })
          end

          it 'handles features with empty files array' do
            empty_files_assignments = {
              'Empty Files Feature' => { 'files' => [] }
            }

            result = described_class.map_tests_by_assignment(test_suites, empty_files_assignments)
            expect(result).to eq('Empty Files Feature' => { count: 0, pending: 0 })
          end

          it 'processes test files that don\'t match any test suites' do
            nonexistent_assignments = {
              'Nonexistent Files' => {
                'files' => ['src/components/Nonexistent/Component.test.js']
              }
            }

            result = described_class.map_tests_by_assignment(test_suites, nonexistent_assignments)
            expect(result).to eq('Nonexistent Files' => { count: 0, pending: 0 })
          end

          it 'correctly categorizes tests by status' do
            status_test_suites = [
              {
                'name' => '/Users/dev/project/src/StatusTest.test.js',
                'assertionResults' => [
                  { 'status' => 'passed' },    # Should count as normal
                  { 'status' => 'failed' },    # Should count as normal
                  { 'status' => 'pending' },   # Should count as pending
                  { 'status' => 'skipped' },   # Should count as pending
                  { 'status' => 'todo' }       # Should count as pending
                ]
              }
            ]

            status_assignments = {
              'Status Tests' => {
                'files' => ['src/StatusTest.test.js']
              }
            }

            result = described_class.map_tests_by_assignment(status_test_suites, status_assignments)
            expect(result).to eq('Status Tests' => { count: 2, pending: 3 })
          end
        end
      end
    end
  end
end
