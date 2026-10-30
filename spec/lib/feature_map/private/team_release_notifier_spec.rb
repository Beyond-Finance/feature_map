# @feature Core Library
# frozen_string_literal: true

require 'octokit'
require 'slack-ruby-client'

module FeatureMap
  RSpec.describe Private::TeamReleaseNotifier do
    let(:release_tag) { 'v2025.01.01.12.59' }
    let(:release_ref) { "refs/tags/#{release_tag}" }
    let(:github_token) { 'abc123-github-token' }
    let(:full_repo_name) { 'Beyond-Finance/glue' }
    let(:display_name) { 'Glue' }
    let(:team_slack_webhooks) do
      {
        'ABC Team' => 'https://hooks.slack.com/services/T1234/B6789/abc111',
        'XYZ Team' => 'https://hooks.slack.com/services/T1234/B6789/abc222'
      }
    end

    describe 'constructor' do
      it 'initializes a TeamReleaseNotifier instance' do
        instance = described_class.new(release_ref, github_token, full_repo_name, display_name, team_slack_webhooks)
        expect(instance.release_tag).to eq(release_tag)
        expect(instance.github_client).to be_a(Octokit::Client)
      end

      context 'when the specified release ref does not match the expected format' do
        let(:release_ref) { release_tag }

        it 'raises an error' do
          expect do
            described_class.new(release_ref, github_token, full_repo_name, display_name,
                                team_slack_webhooks)
          end.to raise_error(RuntimeError, /Release commit reference must be a tag/i)
        end
      end
    end

    describe '#notify' do
      subject(:notifier) { described_class.new(release_ref, github_token, full_repo_name, display_name, team_slack_webhooks) }

      let(:github_client) { instance_double(Octokit::Client, releases: github_releases) }
      let(:github_releases) do
        [double('Release', tag_name: release_tag, draft: false, prerelease: false),
         double('Release', tag_name: previous_release_tag, draft: false, prerelease: false)]
      end
      let(:previous_release_tag) { 'v2024.12.31.18.30' }
      let(:commit_shas) { %w[1234abcd 9876dcba] }
      let(:commit_logs) do
        commit_shas.map.with_index do |sha, index|
          "#{sha} ABC-123 | CHORE | Sample commit #{index + 1} (##{1001 + index})"
        end.join("\n")
      end

      let(:commit_files) do
        {
          commit_shas[0] => ['app/services/create_program.rb', 'app/services/cancel_transaction.rb',
                             'app/jobs/send_enrollment_agreement_job.rb'],
          commit_shas[1] => ['app/services/fetch_credit_report.rb', 'app/jobs/onboard_client_job.rb']
        }
      end

      let(:target_team_webhook) { stub_request(:post, team_slack_webhooks['ABC Team']) }

      before do
        allow(Octokit::Client).to receive(:new).and_return(github_client)
        allow(notifier).to receive(:puts)
        allow(notifier).to receive(:`).with("git fetch --depth 100 origin #{release_tag}").and_return(nil)
        allow(notifier).to receive(:`).with("git fetch -n origin refs/tags/#{release_tag}:refs/tags/#{release_tag}").and_return(nil)
        allow(notifier).to receive(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}").and_return(nil)
        allow(notifier).to receive(:`).with("git log --oneline --decorate-refs-exclude=refs/tags \"#{previous_release_tag}\"..\"#{release_tag}\"").and_return(commit_logs)
        commit_shas.each do |sha|
          allow(notifier).to receive(:`).with("git show --pretty=\"\" --name-only #{sha}").and_return(commit_files[sha].join("\n"))
        end
        target_team_webhook.to_return(status: 201) unless team_slack_webhooks['ABC Team'].nil?
        allow(FeatureMap).to receive(:group_commits) do |commits|
          commit123 = commits.find { |commit| commit.sha == '1234abcd' }
          commit987 = commits.find { |commit| commit.sha == '9876dcba' }

          if commit123.nil? || commit987.nil?
            {}
          else
            { 'ABC Team' => { 'Onboarding' => [commit987], 'Program Management' => [commit123, commit987] } }
          end
        end

        allow(FeatureMap).to receive(:generate_release_notification).and_return([{
                                                                                  type: 'section',
                                                                                  text: {
                                                                                    type: 'mrkdwn',
                                                                                    text: "*_Onboarding_*\n• ABC-123 | CHORE | Sample commit 1 ..."
                                                                                  }
                                                                                }])
      end

      it 'loads the last 100 commits from Github to ensure comparisons within the local git history produce valid results' do
        notifier.notify
        expect(notifier).to have_received(:`).with("git fetch --depth 100 origin #{release_tag}")
      end

      it 'identifies and loads the previous release tag' do
        notifier.notify
        expect(notifier).to have_received(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}")
      end

      context 'when no pending commits are found' do
        let(:commit_shas) { [] }

        it 'does not post any team release notifications' do
          notifier.notify
          expect(target_team_webhook).not_to have_been_requested
        end
      end

      context 'when the specified release is not the recent Github release' do
        let(:github_releases) do
          [
            double('Release', tag_name: 'v2025.01.03.01.01', draft: false, prerelease: false),
            double('Release', tag_name: release_tag, draft: false, prerelease: false),
            double('Release', tag_name: previous_release_tag, draft: false, prerelease: false),
            double('Release', tag_name: 'v2024.12.28.00.00', draft: false, prerelease: false)
          ]
        end

        it 'properly identifies the previous release tag as the one immediately preceding the specified release tag' do
          notifier.notify
          expect(notifier).to have_received(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}")
        end
      end

      context 'when a draft release immediately precedes the specified release' do
        let(:github_releases) do
          [
            double('Release', tag_name: release_tag, draft: false, prerelease: false),
            double('Release', tag_name: 'v2025.01.01.01.01', draft: true, prerelease: false),
            double('Release', tag_name: previous_release_tag, draft: false, prerelease: false),
            double('Release', tag_name: 'v2025.01.01.00.00', draft: false, prerelease: false)
          ]
        end

        it 'ignores the draft release and uses the preceding published release' do
          notifier.notify
          expect(notifier).to have_received(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}")
        end
      end

      context 'when a prerealease immediately precedes the specified release' do
        let(:github_releases) do
          [
            double('Release', tag_name: release_tag, draft: false, prerelease: false),
            double('Release', tag_name: 'v2025.01.01.01.01', draft: false, prerelease: true),
            double('Release', tag_name: previous_release_tag, draft: false, prerelease: false),
            double('Release', tag_name: 'v2024.12.31.23.59', draft: false, prerelease: false)
          ]
        end

        it 'ignores the prerelease and uses the preceding published release' do
          notifier.notify
          expect(notifier).to have_received(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}")
        end
      end

      it 'groups all commits in the release according to the impacted features on a per-team basis' do
        notifier.notify
        expect(FeatureMap).to have_received(:group_commits) do |commits|
          expect(commits.length).to eq(2)
          commit_files.each_with_index do |(commit_sha, commit_files), index|
            commit = commits.find { |c| c.sha == commit_sha }
            expect(commit).not_to be_nil
            expect(commit.description).to eq("ABC-123 | CHORE | Sample commit #{index + 1}")
            expect(commit.pull_request_number).to eq((1001 + index).to_s)
            expect(commit.files).to eq(commit_files)
          end
        end
      end

      context 'when a team has no impacted features in the specified release' do
        let(:commit_shas) { %w[dbca5432 acdb6789] }
        let(:commit_files) do
          {
            'dbca5432' => ['app/models/program.rb'],
            'acdb6789' => ['config/sidekiq.yml']
          }
        end

        it 'does not trigger a Slack notfication for the team' do
          notifier.notify
          expect(target_team_webhook).not_to have_been_requested
        end
      end

      context 'when a team has impacted features in the specified release' do
        context 'when NO Slack webhook URL is configured for the team' do
          let(:team_slack_webhooks) { {} }

          it 'does not trigger a Slack notfication for the team' do
            notifier.notify
          end
        end

        context 'when a Slack webhook URL is configured for the team' do
          let(:expected_message) do
            {
              blocks: [
                {
                  type: 'header',
                  text: {
                    type: 'plain_text',
                    text: ':shipit: v2025.01.01.12.59 Released in Glue'
                  }
                },
                {
                  type: 'section',
                  text: {
                    type: 'mrkdwn',
                    text: "*_Onboarding_*\n• ABC-123 | CHORE | Sample commit 1 ..."
                  }
                }
              ]
            }
          end

          it 'triggers a Slack notfication for the team' do
            target_team_webhook.with(body: expected_message.to_json)
            notifier.notify
            expect(target_team_webhook).to have_been_requested
          end
        end
      end
    end
  end
end
