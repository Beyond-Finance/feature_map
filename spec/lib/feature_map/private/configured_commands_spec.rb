# @feature Core Library
# frozen_string_literal: true

require 'octokit'
require 'slack-ruby-client'

module FeatureMap
  RSpec.describe Private::ConfiguredCommands do
    let(:repository_settings) do
      {
        'repository' => { 'url' => 'https://github.com/example-org/example-app' },
        'documentation_site_url' => 'https://example-org.github.io/example-app/'
      }
    end

    describe 'when the command section is not configured' do
      before { write_configuration(**repository_settings) }

      {
        github_pr_annotation: Private::PullRequestAnnotator,
        slack_release_log: Private::ReleaseLogPublisher,
        slack_team_notifications: Private::TeamReleaseNotifier
      }.each do |command, command_class|
        it "skips #{command} with a message and does nothing else" do
          expect(command_class).not_to receive(:new)

          expect { described_class.public_send(command) }.to output(/'#{command}' is not configured .* Skipping/).to_stdout
        end
      end
    end

    describe '.github_pr_annotation' do
      let(:annotator) { instance_double(Private::PullRequestAnnotator, announce: nil) }
      let(:base_metrics_path) { Pathname.pwd.join('base_metrics.yml').to_s }

      before do
        write_file('base_metrics.yml', "---\nfeatures: {}\n")
        write_configuration(
          **repository_settings,
          'github_pr_annotation' => {
            'github_token' => "<%= ENV.fetch('ACCESS_TOKEN_GITHUB', '') %>",
            'pr_number' => "<%= ENV.fetch('PR_NUMBER', '') %>",
            'base_metrics_path' => "<%= ENV.fetch('BASE_METRICS_PATH', '') %>"
          }
        )
        stub_const('ENV', ENV.to_h.merge('ACCESS_TOKEN_GITHUB' => 'gh-token', 'PR_NUMBER' => '1234', 'BASE_METRICS_PATH' => base_metrics_path))
      end

      it 'builds the annotator from the config and announces' do
        expect(Private::PullRequestAnnotator).to receive(:new)
          .with('gh-token', 'example-org/example-app', '1234', base_metrics_path, 'https://example-org.github.io/example-app/#/')
          .and_return(annotator)

        described_class.github_pr_annotation

        expect(annotator).to have_received(:announce)
      end

      it 'raises when repository.url is not set' do
        write_configuration('github_pr_annotation' => { 'github_token' => 'gh-token', 'pr_number' => '1', 'base_metrics_path' => base_metrics_path })

        expect { described_class.github_pr_annotation }.to raise_error("'repository.url' must be set in .feature_map/config.yml")
      end

      it 'raises naming the missing setting when the GitHub token is empty' do
        stub_const('ENV', ENV.to_h.merge('ACCESS_TOKEN_GITHUB' => ''))

        expect { described_class.github_pr_annotation }.to raise_error("'github_pr_annotation.github_token' must be set in .feature_map/config.yml")
      end
    end

    describe '.slack_release_log' do
      let(:publisher) { instance_double(Private::ReleaseLogPublisher, publish: nil) }

      before do
        write_file('.feature_map/config.yml', <<~CONFIG)
          repository:
            url: https://github.com/example-org/example-app
          documentation_site_url: https://example-org.github.io/example-app/
          slack_release_log:
            display_name: Example App
            github_token: gh-token
            slack_api_token: <%= ENV.fetch('RELEASE_LOG_SLACK_API_TOKEN', '') %>
            slack_app_user_id: U1234ABCD
            slack_channel: '#release-log'
            slack_thread_parent_ts: '<%= ENV.fetch('RELEASE_LOG_SLACK_THREAD_PARENT_TS', '') %>'
        CONFIG
        stub_const('ENV', ENV.to_h.merge('RELEASE_LOG_SLACK_THREAD_PARENT_TS' => '1234567890.100000'))
      end

      context 'when the repository configures a main branch' do
        before do
          write_file('.feature_map/config.yml', File.read('.feature_map/config.yml').sub('repository:', "repository:\n  main_branch: trunk"))
        end

        it 'passes it to the publisher' do
          expect(Private::ReleaseLogPublisher).to receive(:new)
            .with(anything, anything, anything, anything, 'trunk', anything, anything, anything, anything)
            .and_return(publisher)

          described_class.slack_release_log
        end
      end

      it 'strips a trailing .git from the repository url' do
        write_file('.feature_map/config.yml', File.read('.feature_map/config.yml').sub('example-org/example-app', 'example-org/example-app.git'))
        expect(Private::ReleaseLogPublisher).to receive(:new)
          .with(anything, 'example-org/example-app', anything, anything, anything, anything, anything, anything, anything)
          .and_return(publisher)

        described_class.slack_release_log
      end

      it 'builds the publisher from the config, keeping the thread timestamp exactly as written' do
        expect(Private::ReleaseLogPublisher).to receive(:new)
          .with('gh-token', 'example-org/example-app', 'Example App', 'https://example-org.github.io/example-app/#/', 'main', '', 'U1234ABCD', '#release-log', '1234567890.100000')
          .and_return(publisher)

        described_class.slack_release_log

        expect(publisher).to have_received(:publish)
      end
    end

    describe '.slack_team_notifications' do
      let(:notifier) { instance_double(Private::TeamReleaseNotifier, notify: nil) }
      let(:section) do
        {
          'github_token' => 'gh-token',
          'release_ref' => 'refs/tags/v1',
          'teams' => { 'Sales' => "<%= ENV.fetch('SALES_SLACK_WEBHOOK', '') %>" }
        }
      end

      before do
        write_configuration(**repository_settings, 'slack_team_notifications' => section)
        stub_const('ENV', ENV.to_h.merge('SALES_SLACK_WEBHOOK' => 'https://hooks.slack.com/services/abc'))
      end

      it 'uses the raw repo name when no display name is configured' do
        expect(Private::TeamReleaseNotifier).to receive(:new)
          .with('refs/tags/v1', 'gh-token', 'example-org/example-app', 'example-app', { 'Sales' => 'https://hooks.slack.com/services/abc' })
          .and_return(notifier)

        described_class.slack_team_notifications

        expect(notifier).to have_received(:notify)
      end

      context 'when a display name is configured' do
        let(:section) { super().merge('display_name' => 'Example App') }

        it 'uses it in the notification' do
          expect(Private::TeamReleaseNotifier).to receive(:new)
            .with('refs/tags/v1', 'gh-token', 'example-org/example-app', 'Example App', anything)
            .and_return(notifier)

          described_class.slack_team_notifications
        end
      end

      context 'when a team webhook is empty' do
        before { stub_const('ENV', ENV.to_h.merge('SALES_SLACK_WEBHOOK' => '')) }

        it 'passes an empty webhook so the notifier skips that team' do
          expect(Private::TeamReleaseNotifier).to receive(:new)
            .with(anything, anything, anything, anything, { 'Sales' => '' })
            .and_return(notifier)

          described_class.slack_team_notifications
        end
      end
    end
  end
end
