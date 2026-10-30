# @feature Core Library
# frozen_string_literal: true

require 'octokit'

module FeatureMap
  RSpec.describe Private::TeamReleaseNotifier do
    subject(:notifier) { described_class.new(release_ref, 'github-token', 'Beyond-Finance/glue', 'Glue', team_slack_webhooks) }

    let(:release_tag) { 'v2025.01.01.12.59' }
    let(:release_ref) { "refs/tags/#{release_tag}" }
    let(:previous_release_tag) { 'v2024.12.31.18.30' }
    let(:team_slack_webhooks) do
      {
        'Team A' => 'https://hooks.slack.com/services/T1234/B6789/team-a',
        'Team B' => 'https://hooks.slack.com/services/T1234/B6789/team-b',
        'Team C' => 'https://hooks.slack.com/services/T1234/B6789/team-c'
      }
    end
    let(:github_client) do
      instance_double(
        Octokit::Client,
        releases: [
          double('Release', tag_name: release_tag, draft: false, prerelease: false),
          double('Release', tag_name: previous_release_tag, draft: false, prerelease: false)
        ]
      )
    end
    let(:commit_logs) do
      [
        'aaa111 ABC-123 | CHORE | Change across two features (#111)',
        'bbb222 ABC-123 | CHORE | Foo only change (#222)'
      ].join("\n")
    end
    let(:commit_files) do
      {
        'aaa111' => ['app/my_file.rb', 'app/my_error.rb'],
        'bbb222' => ['app/my_file.rb']
      }
    end
    let!(:team_a_request) { stub_request(:post, team_slack_webhooks['Team A']).to_return(status: 200) }
    let!(:team_b_request) { stub_request(:post, team_slack_webhooks['Team B']).to_return(status: 200) }
    let!(:team_c_request) { stub_request(:post, team_slack_webhooks['Team C']).to_return(status: 200) }

    before do
      create_validation_artifacts
      create_files_with_team_assignments
      write_file('.feature_map/assignments.yml', <<~CONTENTS)
        ---
        files:
        features:
          Bar:
            files:
            - app/my_error.rb
            - app/other_team_b_stuff.rb
          Foo:
            files:
            - app/my_file.rb
            - app/foo_stuff_owned_by_team_a.rb
            - app/foo_stuff_owned_by_team_b.rb
      CONTENTS
      write_configuration(
        'unassigned_globs' => ['.feature_map/config.yml', 'config/code_ownership.yml'],
        'skip_code_ownership' => false,
        'documentation_site_url' => 'https://beyond-finance.github.io/glue/',
        'repository' => { 'url' => 'https://github.com/beyond-finance/glue' }
      )
      FeatureMap.bust_caches!

      allow(Octokit::Client).to receive(:new).and_return(github_client)
      allow(notifier).to receive(:puts)
      allow(notifier).to receive(:`).with("git fetch --depth 100 origin #{release_tag}").and_return(nil)
      allow(notifier).to receive(:`).with("git fetch -n origin refs/tags/#{release_tag}:refs/tags/#{release_tag}").and_return(nil)
      allow(notifier).to receive(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}").and_return(nil)
      allow(notifier).to receive(:`).with("git log --oneline --decorate-refs-exclude=refs/tags \"#{previous_release_tag}\"..\"#{release_tag}\"").and_return(commit_logs)
      commit_files.each do |sha, files|
        allow(notifier).to receive(:`).with("git show --pretty=\"\" --name-only #{sha}").and_return(files.join("\n"))
      end
    end

    it 'posts a message with the release header and the affected features to each team responsible for them' do
      notifier.notify

      expect(team_a_request.with { |request| message_text(request) =~ /Foo/ && message_text(request) !~ /Bar/ }).to have_been_requested
      expect(team_b_request.with { |request| message_text(request) =~ /Foo/ && message_text(request) =~ /Bar/ }).to have_been_requested
    end

    it 'titles the message with the release tag and display name' do
      notifier.notify

      expect(team_a_request.with { |request| JSON.parse(request.body)['blocks'].first.dig('text', 'text') == ':shipit: v2025.01.01.12.59 Released in Glue' }).to have_been_requested
    end

    it 'links each feature to the documentation site and each commit to its pull request' do
      notifier.notify

      expect(team_a_request.with { |request| message_text(request).include?('https://beyond-finance.github.io/glue/#/Foo') }).to have_been_requested
      expect(team_a_request.with { |request| message_text(request).include?('Foo only change (<https://github.com/beyond-finance/glue/pull/222|#222>)') }).to have_been_requested
    end

    it 'does not post to teams with no affected features' do
      notifier.notify

      expect(team_c_request).not_to have_been_requested
    end

    def message_text(request)
      JSON.parse(request.body)['blocks'].filter_map { |block| block.dig('text', 'text') }.join("\n")
    end
  end
end
