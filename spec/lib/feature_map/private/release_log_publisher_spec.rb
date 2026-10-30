# @feature Core Library
# frozen_string_literal: true

require 'octokit'
require 'slack-ruby-client'

module FeatureMap
  RSpec.describe Private::ReleaseLogPublisher do
    subject(:publisher) { described_class.new(github_token, full_repo_name, display_name, doc_site_base_url, slack_token, slack_app_user_id, slack_channel, slack_thread_parent_ts) }

    let(:github_client) { instance_double(Octokit::Client, releases: github_releases) }
    let(:slack_client) { instance_double(Slack::Web::Client, auth_test: nil, chat_postMessage: nil, conversations_replies: slack_thread_messages_response, chat_delete: nil) }

    let(:github_token) { 'abc123-github-token' }
    let(:full_repo_name) { 'Beyond-Finance/glue' }
    let(:display_name) { 'Glue' }
    let(:doc_site_base_url) { 'https://beyond-finance.github.io/glue/#/' }
    let(:slack_token) { 'xoxb-123456789-abcd' }
    let(:slack_app_user_id) { 'U1234ABCD' }
    let(:slack_channel) { '#release-log-testing' }
    let(:slack_thread_parent_ts) { '1234567890.123456' }

    let(:github_releases) { [double('Release', tag_name: previous_release_tag, draft: false, prerelease: false)] }
    let(:previous_release_tag) { 'v2025.01.01.12.59' }

    let(:slack_thread_messages_response) { { 'ok' => true, 'messages' => slack_thread_messages } }
    let(:slack_thread_messages) { [] }

    let(:commit_shas) { %w[1234abcd abcd4321 9876dcba fedc8642] }
    let(:commit_logs) do
      commit_shas.map.with_index do |sha, index|
        include_pr_number = (index != 1)
        "#{sha} ABC-123 | CHORE | Sample commit #{index + 1}#{" (##{1001 + index})" if include_pr_number}"
      end.join("\n")
    end

    let(:commit_files) do
      {
        commit_shas[0] => ['app/services/create_program.rb', 'app/services/cancel_transaction.rb',
                           'app/jobs/send_enrollment_agreement_job.rb'],
        commit_shas[1] => ['app/services/fetch_credit_report.rb', 'app/jobs/onboard_client_job.rb'],
        commit_shas[2] => ['config/cft.yml'],
        commit_shas[3] => ['app/services/create_program.rb', 'app/services/fetch_credit_report.rb',
                           'app/jobs/onboard_client_job.rb', 'app/services/process_doc.rb',
                           'app/jobs/sync_transactions.rb', 'app/services/negotiate_settlement.rb']
      }
    end

    let(:file_to_feature_map) do
      {
        'app/services/create_program.rb' => 'Program Management',
        'app/services/cancel_transaction.rb' => 'Onboarding',
        'app/jobs/send_enrollment_agreement_job.rb' => 'Program Management',
        'app/services/fetch_credit_report.rb' => 'Enrollment Agreements',
        'app/jobs/onboard_client_job.rb' => 'Onboarding',
        'app/services/process_doc.rb' => 'Document Processing',
        'app/jobs/sync_transactions.rb' => 'Transaction Management',
        'app/services/negotiate_settlement.rb' => 'Automated Negotiations',
        'config/cft.yml' => nil
      }
    end

    before do
      allow(Octokit::Client).to receive(:new).and_return(github_client)
      allow(Slack::Web::Client).to receive(:new).and_return(slack_client)
      allow(publisher).to receive(:puts)
      allow(publisher).to receive(:`).with('git fetch --depth 100 origin main').and_return(nil)
      allow(publisher).to receive(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}").and_return(nil)
      allow(publisher).to receive(:`).with("git log --oneline --decorate-refs-exclude=refs/tags \"#{previous_release_tag}\"..\"origin/main\"").and_return(commit_logs)
      commit_shas.each do |sha|
        allow(publisher).to receive(:`).with("git show --pretty=\"\" --name-only #{sha}").and_return(commit_files[sha].join("\n"))
      end
      allow(FeatureMap).to receive(:for_file) do |file|
        feature_name = file_to_feature_map[file]
        feature_name ? FeatureMap::CodeFeatures::Feature.from_hash('name' => feature_name) : nil
      end
    end

    describe '#publish' do
      let(:expected_message) do
        [
          {
            type: 'header',
            text: {
              type: 'plain_text',
              text: ':shipit: Glue Changes'
            }
          },
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "Current Commit: <https://github.com/Beyond-Finance/glue/compare/v2025.01.01.12.59...1234abcd|1234abcd>\n"
            }
          },
          {
            type: 'rich_text',
            elements: [
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 0,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'ABC-123 | CHORE | Sample commit 1'
                      },
                      {
                        type: 'text',
                        text: ' ('
                      },
                      {
                        type: 'link',
                        url: 'https://github.com/Beyond-Finance/glue/pull/1001',
                        text: '#1001'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'Program Management ('
                      },
                      {
                        type: 'link',
                        url: 'https://beyond-finance.github.io/glue/#/Program%20Management',
                        text: 'View Documentation'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'Onboarding ('
                      },
                      {
                        type: 'link',
                        url: 'https://beyond-finance.github.io/glue/#/Onboarding',
                        text: 'View Documentation'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 0,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'ABC-123 | CHORE | Sample commit 2'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'Enrollment Agreements ('
                      },
                      {
                        type: 'link',
                        url: 'https://beyond-finance.github.io/glue/#/Enrollment%20Agreements',
                        text: 'View Documentation'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'Onboarding ('
                      },
                      {
                        type: 'link',
                        url: 'https://beyond-finance.github.io/glue/#/Onboarding',
                        text: 'View Documentation'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 0,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'ABC-123 | CHORE | Sample commit 3'
                      },
                      {
                        type: 'text',
                        text: ' ('
                      },
                      {
                        type: 'link',
                        url: 'https://github.com/Beyond-Finance/glue/pull/1003',
                        text: '#1003'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'No Feature'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 0,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'ABC-123 | CHORE | Sample commit 4'
                      },
                      {
                        type: 'text',
                        text: ' ('
                      },
                      {
                        type: 'link',
                        url: 'https://github.com/Beyond-Finance/glue/pull/1004',
                        text: '#1004'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'Program Management ('
                      },
                      {
                        type: 'link',
                        url: 'https://beyond-finance.github.io/glue/#/Program%20Management',
                        text: 'View Documentation'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'Enrollment Agreements ('
                      },
                      {
                        type: 'link',
                        url: 'https://beyond-finance.github.io/glue/#/Enrollment%20Agreements',
                        text: 'View Documentation'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'Onboarding ('
                      },
                      {
                        type: 'link',
                        url: 'https://beyond-finance.github.io/glue/#/Onboarding',
                        text: 'View Documentation'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'Document Processing ('
                      },
                      {
                        type: 'link',
                        url: 'https://beyond-finance.github.io/glue/#/Document%20Processing',
                        text: 'View Documentation'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'Transaction Management ('
                      },
                      {
                        type: 'link',
                        url: 'https://beyond-finance.github.io/glue/#/Transaction%20Management',
                        text: 'View Documentation'
                      },
                      {
                        type: 'text',
                        text: ')'
                      }
                    ]
                  }
                ]
              },
              {
                type: 'rich_text_list',
                style: 'bullet',
                indent: 1,
                elements: [
                  {
                    type: 'rich_text_section',
                    elements: [
                      {
                        type: 'text',
                        text: 'And 1 other feature...'
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      end

      it 'loads the last 100 commits from Github to ensure comparisons within the local git history produce valid results' do
        publisher.publish
        expect(publisher).to have_received(:`).with('git fetch --depth 100 origin main')
      end

      it 'identifies and loads the previous release tag' do
        publisher.publish
        expect(publisher).to have_received(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}")
      end

      context 'when no pending commits are found' do
        let(:commit_shas) { [] }

        it 'does not post anything to the release log' do
          publisher.publish
          expect(slack_client).not_to have_received(:chat_postMessage)
        end
      end

      context 'when the most recent Github release is a draft' do
        let(:github_releases) do
          [
            double('Release', tag_name: 'v2025.01.03.01.01', draft: true, prerelease: false),
            double('Release', tag_name: previous_release_tag, draft: false, prerelease: false),
            double('Release', tag_name: 'v2025.01.01.00.00', draft: false, prerelease: false)
          ]
        end

        it 'ignores the draft release and posts all changes since the previous published release' do
          publisher.publish
          expect(publisher).to have_received(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}")
        end
      end

      context 'when the most recent Github release is a prerelease' do
        let(:github_releases) do
          [
            double('Release', tag_name: 'v2025.01.03.01.01', draft: false, prerelease: true),
            double('Release', tag_name: previous_release_tag, draft: false, prerelease: false),
            double('Release', tag_name: 'v2024.12.31.23.59', draft: false, prerelease: false)
          ]
        end

        it 'ignores the prerelease and posts all changes since the previous published release' do
          publisher.publish
          expect(publisher).to have_received(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}")
        end
      end

      it 'looks up the feature for each file in the current release' do
        publisher.publish
        expect(FeatureMap).to have_received(:for_file).exactly(commit_files.values.sum(&:length)).times
        commit_files.values.flatten.group_by(&:to_s).transform_values(&:length).each do |file, count|
          expect(FeatureMap).to have_received(:for_file).with(file).exactly(count).times
        end
      end

      it 'publishes the resulting release log message' do
        publisher.publish
        expect(slack_client).to have_received(:chat_postMessage).with(channel: slack_channel, blocks: expected_message, thread_ts: slack_thread_parent_ts)
      end

      context 'when no Slack API token is set' do
        let(:slack_token) { nil }

        it 'does NOT publish any release log message' do
          publisher.publish
          expect(slack_client).not_to have_received(:chat_postMessage)
        end
      end

      context 'when a blank Slack API token is set' do
        let(:slack_token) { '' }

        it 'does NOT publish any release log message' do
          publisher.publish
          expect(slack_client).not_to have_received(:chat_postMessage)
        end
      end

      context 'when no target Slack channel is set' do
        let(:slack_channel) { nil }

        it 'does NOT publish any release log message' do
          publisher.publish
          expect(slack_client).not_to have_received(:chat_postMessage)
        end
      end

      context 'when a blank target Slack channel is set' do
        let(:slack_channel) { '' }

        it 'does NOT publish any release log message' do
          publisher.publish
          expect(slack_client).not_to have_received(:chat_postMessage)
        end
      end

      context 'when no Slack parent message timestamp is set' do
        let(:slack_thread_parent_ts) { nil }

        it 'does NOT publish any release log message' do
          publisher.publish
          expect(slack_client).not_to have_received(:chat_postMessage)
        end
      end

      context 'when a blank Slack parent message timestamp is set' do
        let(:slack_thread_parent_ts) { '' }

        it 'does NOT publish any release log message' do
          publisher.publish
          expect(slack_client).not_to have_received(:chat_postMessage)
        end
      end

      context 'when the Slack auth test fails' do
        let(:auth_failure_error) { Slack::Web::Api::Errors::InvalidAuth.new('invalid_auth') }

        before { allow(slack_client).to receive(:auth_test).and_raise(auth_failure_error) }

        it 'raises an exception to fail the job' do
          expect { publisher.publish }.to raise_error(auth_failure_error)
        end

        it 'does NOT publish any release log message' do
          expect { publisher.publish }.to raise_error(Slack::Web::Api::Errors::InvalidAuth)
          expect(slack_client).not_to have_received(:chat_delete)
        end
      end

      context 'when the request to fetch past release log messages fails' do
        let(:conversation_fetch_error) { Slack::Web::Api::Errors::ThreadNotFound.new('thread_not_found') }

        before { allow(slack_client).to receive(:conversations_replies).and_raise(conversation_fetch_error) }

        it 'raises an exception to fail the job' do
          expect { publisher.publish }.to raise_error(conversation_fetch_error)
        end

        it 'does NOT delete any past release log messages' do
          expect { publisher.publish }.to raise_error(Slack::Web::Api::Errors::ThreadNotFound)
          expect(slack_client).not_to have_received(:chat_delete)
        end
      end

      it 'fetches the conversation thread for the release log parent thread' do
        publisher.publish
        expect(slack_client).to have_received(:conversations_replies).with(channel: slack_channel, ts: slack_thread_parent_ts)
      end

      context 'when past release log messages are successfully fetched' do
        let(:one_day_ago_ts) { Time.now.to_i - (24 * 60 * 60) }
        let(:recent_message1) { { 'user' => slack_app_user_id, 'ts' => "#{Time.now.to_i}.123456" } }
        let(:recent_message2) { { 'user' => slack_app_user_id, 'ts' => "#{one_day_ago_ts}.123456" } }
        let(:outdated_message1) { { 'user' => slack_app_user_id, 'ts' => "#{one_day_ago_ts - 1}.123456" } }
        let(:outdated_message2) { { 'user' => slack_app_user_id, 'ts' => "#{one_day_ago_ts - 360}.123456" } }
        let(:other_author_message1) { { 'user' => 'U9876FEDC', 'ts' => "#{one_day_ago_ts - 1200}.123456" } }
        let(:other_author_message2) { { 'user' => 'U5432DCBA', 'ts' => "#{Time.now.to_i}.123456" } }

        before { allow(Time).to receive(:now).and_return(Time.at(Time.now.to_i)) }

        context 'when past messages include messages posted by the Slack app more than one day ago' do
          let(:slack_thread_messages) { [recent_message1, outdated_message1, other_author_message1, outdated_message2] }

          it 'deletes all outdated release log messages' do
            publisher.publish
            expect(slack_client).to have_received(:chat_delete).exactly(2).times
            expect(slack_client).to have_received(:chat_delete).with(channel: slack_channel, ts: outdated_message1['ts'])
            expect(slack_client).to have_received(:chat_delete).with(channel: slack_channel, ts: outdated_message2['ts'])
          end
        end

        context 'when past messages were posted less than one day ago' do
          let(:slack_thread_messages) { [recent_message1, recent_message2] }

          it 'does NOT delete these recent release log messages' do
            publisher.publish
            expect(slack_client).not_to have_received(:chat_delete)
          end
        end

        context 'when past messages were posted by a user other than the Slack app' do
          let(:slack_thread_messages) { [other_author_message1, other_author_message2] }

          it 'does NOT delete these messages authored by other users' do
            publisher.publish
            expect(slack_client).not_to have_received(:chat_delete)
          end
        end

        context 'when deleting a message raises MessageNotFound' do
          let(:slack_thread_messages) { [outdated_message1, outdated_message2] }

          before do
            allow(slack_client).to receive(:chat_delete)
              .with(channel: slack_channel, ts: outdated_message1['ts'])
              .and_raise(Slack::Web::Api::Errors::MessageNotFound.new('message_not_found'))
          end

          it 'logs the error and continues without failing' do
            expect { publisher.publish }.not_to raise_error
            expect(publisher).to have_received(:puts).with(/Message #{outdated_message1['ts']} was already deleted/)
          end

          it 'continues to delete remaining messages' do
            publisher.publish
            expect(slack_client).to have_received(:chat_delete).with(channel: slack_channel, ts: outdated_message2['ts'])
          end
        end
      end
    end
  end
end
