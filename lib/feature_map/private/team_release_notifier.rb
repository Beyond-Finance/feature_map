# @feature Core Library
# frozen_string_literal: true

module FeatureMap
  module Private
    class TeamReleaseNotifier
      MAX_COMMITS_PER_RELEASE = 100

      attr_reader :release_tag, :github_client, :full_repo_name, :display_name, :team_slack_webhooks

      def initialize(release_ref, github_token, full_repo_name, display_name, team_slack_webhooks)
        unless release_ref.start_with?('refs/tags/')
          raise "Release commit reference must be a tag (i.e. start with 'refs/tags/'). Received value: #{release_ref}"
        end

        @release_tag = release_ref[10..]
        @github_client = Octokit::Client.new(access_token: github_token)
        @full_repo_name = full_repo_name
        @display_name = display_name
        @team_slack_webhooks = team_slack_webhooks
      end

      def notify
        commits = lookup_commits_in_release
        puts "Commits in release #{release_tag}:\n#{commits}\n\n"

        grouped_commits = FeatureMap.group_commits(commits)

        deliver_release_notifications(grouped_commits)
      end

      private

      def lookup_commits_in_release
        commit_logs_in_current_release.map do |commit_log|
          commit_info = commit_log.split

          sha = commit_info.shift
          pull_request_number = commit_info.pop[2..-2] if commit_info.last.match?(/^\(#[0-9]+\)$/i)
          description = commit_info.join(' ')
          files = `git show --pretty="" --name-only #{sha}`.split("\n")

          FeatureMap::Commit.new(sha:, description:, pull_request_number:, files:)
        end
      end

      def commit_logs_in_current_release
        previous_release_tag = lookup_previous_release_tag

        load_repo_history
        fetch_tag(previous_release_tag)
        fetch_tag(release_tag)

        command = "git log --oneline --decorate-refs-exclude=refs/tags \"#{previous_release_tag}\"..\"#{release_tag}\""
        puts "Running '#{command}' to identify commits in release #{release_tag}\n"
        commit_logs_in_current_release = `#{command}`
        commit_logs_in_current_release.split("\n")
      end

      def lookup_previous_release_tag
        releases = github_client.releases(full_repo_name)
        published_releases = releases.reject { |release| release.draft || release.prerelease }

        published_releases.each_with_index do |release, index|
          return published_releases[index + 1].tag_name if release.tag_name == release_tag
        end

        raise "No prior release found. Current release tag: #{release_tag}"
      end

      def load_repo_history
        `git fetch --depth #{MAX_COMMITS_PER_RELEASE} origin #{release_tag}`
      end

      def fetch_tag(tag_name)
        command = "git fetch -n origin refs/tags/#{tag_name}:refs/tags/#{tag_name}"

        puts "Running '#{command}' to fetch tag #{tag_name}\n"
        `#{command}`
      end

      def deliver_release_notifications(grouped_commits)
        team_slack_webhooks.each do |team_name, slack_webhook|
          if !grouped_commits[team_name] || grouped_commits[team_name].empty?
            puts "No features for the #{team_name} Team impacted by release #{release_tag}. Skipping notification.\n"
            next
          end

          message_blocks = FeatureMap.generate_release_notification(grouped_commits[team_name])

          message_blocks = [header_block] + message_blocks
          puts "Full Message Content for #{team_name} Team:\n#{message_blocks.to_json}\n"
          if slack_webhook.nil? || slack_webhook.empty?
            puts "No Slack webhook configured for team #{team_name}. Skipping notification delivery.\n\n"
            next
          end

          post_team_notification(slack_webhook, message_blocks)
          puts "Delivered release notification to team #{team_name}\n\n"
        end
      end

      def header_block
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: ":shipit: #{release_tag} Released in #{display_name}"
          }
        }
      end

      def post_team_notification(slack_webhook, message_blocks)
        Faraday.post(slack_webhook, { blocks: message_blocks }.to_json, { 'Content-Type' => 'application/json' })
      end
    end
  end
end
