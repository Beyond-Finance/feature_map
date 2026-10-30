# @feature Core Library
# frozen_string_literal: true

module FeatureMap
  module Private
    class ReleaseLogPublisher
      MAX_COMMITS_PER_RELEASE = 100
      MAX_RELEASE_LOG_MESSAGE_AGE_IN_SECONDS = (24 * 60 * 60)

      MAX_FEATURES_PER_COMMIT = 5

      attr_reader :github_client, :full_repo_name, :display_name, :slack_api_token, :slack_app_user_id, :slack_channel,
                  :slack_thread_parent_ts, :doc_site_base_url

      def initialize(github_token, full_repo_name, display_name, doc_site_base_url, slack_api_token, slack_app_user_id, slack_channel, slack_thread_parent_ts)
        @github_client = Octokit::Client.new(access_token: github_token)
        @full_repo_name = full_repo_name
        @display_name = display_name
        @slack_api_token = slack_api_token
        @slack_app_user_id = slack_app_user_id
        @slack_channel = slack_channel
        @slack_thread_parent_ts = slack_thread_parent_ts
        @doc_site_base_url = doc_site_base_url
      end

      def publish
        previous_release_tag = find_previous_release_tag

        commits = commits_since_release(previous_release_tag)
        if commits.empty?
          puts "No pending commits found.\n"
          return
        end

        puts "Commits since last release:\n#{commits}\n\n"

        features_by_commit = identify_features_for_commits(commits)

        current_commit_sha = commits.first.sha
        slack_message_blocks = build_release_log_message(features_by_commit, previous_release_tag, current_commit_sha)
        post_release_log(slack_message_blocks)
      end

      private

      def commits_since_release(release_tag)
        commit_logs_since(release_tag).map do |commit_log|
          commit_info = commit_log.split

          sha = commit_info.shift
          pull_request_number = commit_info.pop[2..-2] if commit_info.last.match?(/^\(#[0-9]+\)$/i)
          description = commit_info.join(' ')
          files = `git show --pretty="" --name-only #{sha}`.split("\n")

          FeatureMap::Commit.new(sha:, description:, pull_request_number:, files:)
        end
      end

      def commit_logs_since(release_tag)
        load_repo_history
        fetch_tag(release_tag)

        commit_logs_command = "git log --oneline --decorate-refs-exclude=refs/tags \"#{release_tag}\"..\"origin/main\""
        puts "Running '#{commit_logs_command}' to identify commits since release #{release_tag}\n"
        commit_logs_in_current_release = `#{commit_logs_command}`
        commit_logs_in_current_release.split("\n")
      end

      def find_previous_release_tag
        releases = github_client.releases(full_repo_name)
        published_releases = releases.reject { |release| release.draft || release.prerelease }

        return published_releases.first.tag_name unless published_releases.empty?

        raise 'No prior release found.'
      end

      def load_repo_history
        `git fetch --depth #{MAX_COMMITS_PER_RELEASE} origin main`
      end

      def fetch_tag(tag_name)
        command = "git fetch -n origin refs/tags/#{tag_name}:refs/tags/#{tag_name}"

        puts "Running '#{command}' to fetch tag #{tag_name}\n"
        `#{command}`
      end

      def identify_features_for_commits(commits)
        commits.to_h do |commit|
          [commit, commit.files.map { |file| FeatureMap.for_file(file) }.compact.uniq]
        end
      end

      def build_release_log_message(features_by_commit, release_tag, current_commit_sha)
        if features_by_commit.empty?
          puts "No changes identified since previous release. Skipping notification.\n"
          return
        end

        message_blocks = build_release_outline(features_by_commit)

        message_blocks = build_header_blocks(release_tag, current_commit_sha) + message_blocks
        puts "Release Log Message Content:\n#{message_blocks.to_json}\n\n"

        message_blocks
      end

      def post_release_log(message_blocks)
        required_configurations = [
          { value: slack_api_token, label: 'Slack API token' },
          { value: slack_channel, label: 'target Slack channel' },
          { value: slack_thread_parent_ts, label: 'parent Slack message timestamp' }
        ]
        return unless required_configurations.all? do |required_config|
          if required_config[:value].nil? || required_config[:value].empty?
            puts "No #{required_config[:label]} configured. Skipping notification delivery.\n\n"
            next false
          end
          true
        end

        puts 'Verifying Slack Client authentication...'
        slack_client.auth_test

        puts "Posting release log message to thread in #{slack_channel}..."
        slack_client.chat_postMessage(channel: slack_channel, blocks: message_blocks, thread_ts: slack_thread_parent_ts)

        remove_outdated_release_log_messages
      end

      def remove_outdated_release_log_messages
        if slack_app_user_id.nil? || slack_app_user_id.empty?
          puts "No Slack user ID configured for the Slack app. Skipping past release log cleanup.\n\n"
          return
        end

        puts "Fetching release log messages for this repo from thread in #{slack_channel}..."
        thread_messages_response = slack_client.conversations_replies(channel: slack_channel, ts: slack_thread_parent_ts)

        unless thread_messages_response['ok']
          puts "Outdated release log message retrieval failed: #{thread_messages_response.to_json}"
          raise 'Failed to retrieve outdated release log messages.'
        end

        messages_to_delete = thread_messages_response['messages'].filter { |message| outdated_message?(message) }

        puts "Found #{messages_to_delete.length} outdated messages in the release log thread for this repo to be deleted."
        messages_to_delete.each do |message_data|
          delete_outdated_message(message_data)
        end

        puts 'All outdated messages deleted.'
      end

      def delete_outdated_message(message_data)
        slack_client.chat_delete(channel: slack_channel, ts: message_data['ts'])
      rescue Slack::Web::Api::Errors::MessageNotFound => e
        puts "Message #{message_data['ts']} was already deleted: #{e.message}"
      end

      def outdated_message?(slack_message)
        !slack_message['user'].nil? &&
          !slack_message['ts'].nil? &&
          slack_message['user'] == slack_app_user_id &&
          slack_message['ts'].split('.').first.to_i < oldest_relevant_message_ts
      end

      def oldest_relevant_message_ts
        @oldest_relevant_message_ts ||= (Time.now - MAX_RELEASE_LOG_MESSAGE_AGE_IN_SECONDS).to_i
      end

      def build_header_blocks(release_tag, current_commit_sha)
        [
          {
            type: 'header',
            text: {
              type: 'plain_text',
              text: ":shipit: #{display_name} Changes"
            }
          },
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "Current Commit: <https://github.com/#{full_repo_name}/compare/#{release_tag}...#{current_commit_sha}|#{current_commit_sha}>\n"
            }
          }
        ]
      end

      def build_release_outline(features_by_commit)
        return [] if features_by_commit.empty?

        commits = features_by_commit.keys

        commit_bullets = commits.flat_map do |commit|
          [build_commit_bullet(commit)] + build_feature_sub_bullets(features_by_commit[commit])
        end

        [{
          type: 'rich_text',
          elements: commit_bullets
        }]
      end

      def build_commit_bullet(commit)
        commit_description_details = [{ type: 'text', text: commit.description }]

        if commit.pull_request_number
          commit_description_details << { type: 'text', text: ' (' }
          commit_description_details << { type: 'link', url: "https://github.com/#{full_repo_name}/pull/#{commit.pull_request_number}", text: "##{commit.pull_request_number}" }
          commit_description_details << { type: 'text', text: ')' }
        end

        slack_list_item(0, commit_description_details)
      end

      def build_feature_sub_bullets(features)
        return [slack_list_item(1, [{ type: 'text', text: 'No Feature' }])] if features.empty?

        features
          .first(MAX_FEATURES_PER_COMMIT)
          .map { |feature| build_feature_sub_bullet(feature) }
          .tap do |feature_bullets|
            additional_features_count = features.length - MAX_FEATURES_PER_COMMIT
            next unless additional_features_count.positive?

            features_label = additional_features_count > 1 ? 'features' : 'feature'
            feature_bullets << slack_list_item(1,
                                               [{ type: 'text',
                                                  text: "And #{additional_features_count} other #{features_label}..." }])
          end
      end

      def build_feature_sub_bullet(feature)
        feature_description_details = [{ type: 'text', text: "#{feature.name} (" }]
        doc_site_url = "#{doc_site_base_url}#{URI::DEFAULT_PARSER.escape(feature.name)}"
        feature_description_details << { type: 'link', url: doc_site_url, text: 'View Documentation' }
        feature_description_details << { type: 'text', text: ')' }

        slack_list_item(1, feature_description_details)
      end

      def slack_list_item(indent, elements)
        {
          type: 'rich_text_list',
          style: 'bullet',
          indent:,
          elements: [
            {
              type: 'rich_text_section',
              elements:
            }
          ]
        }
      end

      def slack_client
        @slack_client ||= Slack::Web::Client.new(token: slack_api_token)
      end
    end
  end
end
