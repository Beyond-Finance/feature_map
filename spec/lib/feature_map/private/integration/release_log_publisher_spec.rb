# @feature Core Library
# frozen_string_literal: true

require 'octokit'
require 'slack-ruby-client'

module FeatureMap
  RSpec.describe Private::ReleaseLogPublisher do
    subject(:publisher) do
      described_class.new('github-token', 'Beyond-Finance/glue', 'Glue', 'https://beyond-finance.github.io/glue/#/', 'slack-token', 'U1234ABCD', '#release-log', '1234567890.123456')
    end

    let(:previous_release_tag) { 'v2025.01.01.12.59' }
    let(:github_client) { instance_double(Octokit::Client, releases: [double('Release', tag_name: previous_release_tag, draft: false, prerelease: false)]) }
    let(:slack_client) do
      instance_double(
        Slack::Web::Client,
        auth_test: nil,
        chat_postMessage: nil,
        conversations_replies: { 'ok' => true, 'messages' => [] }
      )
    end
    let(:commit_logs) do
      [
        'aaa111 ABC-123 | CHORE | Change across two features (#111)',
        'bbb222 ABC-123 | CHORE | Change to an unassigned file'
      ].join("\n")
    end
    let(:commit_files) do
      {
        'aaa111' => ['app/my_file.rb', 'app/my_error.rb'],
        'bbb222' => ['config/unassigned.yml']
      }
    end
    let(:posted_blocks) do
      publisher.publish
      posted = nil
      expect(slack_client).to have_received(:chat_postMessage) { |**args| posted = args }
      posted
    end

    before do
      create_validation_artifacts
      FeatureMap.bust_caches!

      allow(Octokit::Client).to receive(:new).and_return(github_client)
      allow(Slack::Web::Client).to receive(:new).with(token: 'slack-token').and_return(slack_client)
      allow(publisher).to receive(:puts)
      allow(publisher).to receive(:`).with('git fetch --depth 100 origin main').and_return(nil)
      allow(publisher).to receive(:`).with("git fetch -n origin refs/tags/#{previous_release_tag}:refs/tags/#{previous_release_tag}").and_return(nil)
      allow(publisher).to receive(:`).with("git log --oneline --decorate-refs-exclude=refs/tags \"#{previous_release_tag}\"..\"origin/main\"").and_return(commit_logs)
      commit_files.each do |sha, files|
        allow(publisher).to receive(:`).with("git show --pretty=\"\" --name-only #{sha}").and_return(files.join("\n"))
      end
    end

    it 'posts the release log to the configured thread with the display name in the header' do
      expect(posted_blocks).to include(channel: '#release-log', thread_ts: '1234567890.123456')
      expect(posted_blocks[:blocks].first.dig(:text, :text)).to eq ':shipit: Glue Changes'
    end

    it 'links the current commit to the comparison with the previous release in the repository' do
      current_commit_block = posted_blocks[:blocks][1]

      expect(current_commit_block.dig(:text, :text)).to include('https://github.com/Beyond-Finance/glue/compare/v2025.01.01.12.59...aaa111|aaa111')
    end

    it 'lists each commit with a pull request link and the features it affects with documentation links' do
      list_items = posted_blocks[:blocks].last[:elements]
      texts = list_items.flat_map { |item| item[:elements].flat_map { |section| section[:elements] } }

      expect(texts).to include(
        { type: 'link', url: 'https://github.com/Beyond-Finance/glue/pull/111', text: '#111' },
        { type: 'link', url: 'https://beyond-finance.github.io/glue/#/Foo', text: 'View Documentation' },
        { type: 'link', url: 'https://beyond-finance.github.io/glue/#/Bar', text: 'View Documentation' },
        { type: 'text', text: 'No Feature' }
      )
    end
  end
end
