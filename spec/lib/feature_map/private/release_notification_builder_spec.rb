# @feature Extension System
# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::ReleaseNotificationBuilder do
    describe '.build' do
      before { create_files_with_defined_classes }

      context 'when an empty set of commits is provided' do
        it 'returns an empty array' do
          payload = described_class.build({})
          expect(payload).to eq([])
        end
      end

      context 'when both a repository URL and a documentation site URL are configured' do
        before do
          write_configuration(
            'repository' => {
              'main_branch' => 'main',
              'url' => 'https://github.com/test-org/feature_map'
            },
            'documentation_site_url' => 'https://test-org.github.io/feature_map/'
          )
        end

        context 'when a single commit, impacting a single feature is provided' do
          let(:commit) { Commit.new(sha: 'abc123', description: 'A test change of Foo.', pull_request_number: '123', files: ['app/my_file.rb']) }
          let(:commits_by_feature) { { 'Foo' => [commit] } }

          it 'generates the appropriate block kit payload' do
            payload = described_class.build(commits_by_feature)
            expect(payload).to eq([
                                    {
                                      type: 'section',
                                      text: {
                                        type: 'mrkdwn',
                                        text: "*_Foo_* (<https://test-org.github.io/feature_map/#/Foo|View Documentation>)\n• A test change of Foo. (<https://github.com/test-org/feature_map/pull/123|#123>)"
                                      }
                                    }
                                  ])
          end
        end

        context 'when a single commit, impacting multiple features is provided' do
          let(:commit) { Commit.new(sha: 'abc123', description: 'A test change impacting both Foo and Bar.', pull_request_number: '123', files: ['app/my_file.rb', 'app/my_error.rb']) }
          let(:commits_by_feature) { { 'Foo' => [commit], 'Bar' => [commit] } }

          it 'generates the appropriate block kit payload' do
            payload = described_class.build(commits_by_feature)
            expect(payload).to eq([
                                    {
                                      type: 'section',
                                      text: {
                                        type: 'mrkdwn',
                                        text: "*_Bar_* (<https://test-org.github.io/feature_map/#/Bar|View Documentation>)\n• A test change impacting both Foo and Bar. (<https://github.com/test-org/feature_map/pull/123|#123>)"
                                      }
                                    },
                                    { type: 'divider' },
                                    {
                                      type: 'section',
                                      text: {
                                        type: 'mrkdwn',
                                        text: "*_Foo_* (<https://test-org.github.io/feature_map/#/Foo|View Documentation>)\n• A test change impacting both Foo and Bar. (<https://github.com/test-org/feature_map/pull/123|#123>)"
                                      }
                                    }
                                  ])
          end
        end

        context 'when multiple commits, impacting a single feature are provided' do
          let(:foo_commit1) { Commit.new(sha: 'abc123', description: 'A test change of Foo.', pull_request_number: '123', files: ['app/my_file.rb']) }
          let(:foo_commit2) { Commit.new(sha: '987def', description: 'Another change impacting Foo.', pull_request_number: '987', files: ['app/my_file.rb']) }
          let(:commits_by_feature) { { 'Foo' => [foo_commit1, foo_commit2] } }

          it 'generates the appropriate block kit payload' do
            payload = described_class.build(commits_by_feature)
            expect(payload).to eq([
                                    {
                                      type: 'section',
                                      text: {
                                        type: 'mrkdwn',
                                        text: "*_Foo_* (<https://test-org.github.io/feature_map/#/Foo|View Documentation>)\n• A test change of Foo. (<https://github.com/test-org/feature_map/pull/123|#123>)\n• Another change impacting Foo. (<https://github.com/test-org/feature_map/pull/987|#987>)"
                                      }
                                    }
                                  ])
          end
        end

        context 'when multiple commits, impacting a multiple features are provided' do
          let(:foo_commit) { Commit.new(sha: 'aaa111', description: 'A test change of Foo.', pull_request_number: '111', files: ['app/my_file.rb']) }
          let(:bar_commit) { Commit.new(sha: 'bbb222', description: 'A test change of Bar.', pull_request_number: '222', files: ['app/my_error.rb']) }
          let(:commits_by_feature) { { 'Foo' => [foo_commit], 'Bar' => [bar_commit] } }

          it 'generates the appropriate block kit payload' do
            payload = described_class.build(commits_by_feature)
            expect(payload).to eq([
                                    {
                                      type: 'section',
                                      text: {
                                        type: 'mrkdwn',
                                        text: "*_Bar_* (<https://test-org.github.io/feature_map/#/Bar|View Documentation>)\n• A test change of Bar. (<https://github.com/test-org/feature_map/pull/222|#222>)"
                                      }
                                    },
                                    { type: 'divider' },
                                    {
                                      type: 'section',
                                      text: {
                                        type: 'mrkdwn',
                                        text: "*_Foo_* (<https://test-org.github.io/feature_map/#/Foo|View Documentation>)\n• A test change of Foo. (<https://github.com/test-org/feature_map/pull/111|#111>)"
                                      }
                                    }
                                  ])
          end
        end

        context 'when a commits has no associated pull request' do
          let(:commit) { Commit.new(sha: 'aaa111', description: 'A test change of Foo.', files: ['app/my_file.rb']) }
          let(:commits_by_feature) { { 'Foo' => [commit] } }

          it 'generates a block kit payload with no pull request link' do
            payload = described_class.build(commits_by_feature)
            expect(payload).to eq([
                                    {
                                      type: 'section',
                                      text: {
                                        type: 'mrkdwn',
                                        text: "*_Foo_* (<https://test-org.github.io/feature_map/#/Foo|View Documentation>)\n• A test change of Foo."
                                      }
                                    }
                                  ])
          end
        end

        context 'when set of commits include a \'No Feature\' secton' do
          let(:commit) { Commit.new(sha: 'aaa111', description: 'A test change of Foo.', files: ['app/my_file.rb']) }
          let(:featureless_commit) { Commit.new(sha: 'ddd444', description: 'Change to files that are not assigned to any feature.', files: ['app/featureless_file.rb']) }
          let(:commits_by_feature) { { 'Foo' => [commit], 'No Feature' => [featureless_commit] } }

          it 'excludes the documentation site link for the \'No Feature\' section' do
            payload = described_class.build(commits_by_feature)
            expect(payload).to eq([
                                    {
                                      type: 'section',
                                      text: {
                                        type: 'mrkdwn',
                                        text: "*_Foo_* (<https://test-org.github.io/feature_map/#/Foo|View Documentation>)\n• A test change of Foo."
                                      }
                                    },
                                    { type: 'divider' },
                                    {
                                      type: 'section',
                                      text: {
                                        type: 'mrkdwn',
                                        text: "*_No Feature_*\n• Change to files that are not assigned to any feature."
                                      }
                                    }
                                  ])
          end
        end
      end

      context 'when the repository URL and documentation site URL are NOT configured' do
        let(:commit) { Commit.new(sha: 'abc123', description: 'A test change of Foo.', pull_request_number: '123', files: ['app/my_file.rb']) }
        let(:commits_by_feature) { { 'Foo' => [commit] } }

        it 'omits the documentation link and PR link from the block kit payload' do
          payload = described_class.build(commits_by_feature)
          expect(payload).to eq([
                                  {
                                    type: 'section',
                                    text: {
                                      type: 'mrkdwn',
                                      text: "*_Foo_*\n• A test change of Foo."
                                    }
                                  }
                                ])
        end
      end
    end
  end
end
