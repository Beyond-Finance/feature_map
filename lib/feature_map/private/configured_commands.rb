# @feature Core Library
# frozen_string_literal: true

module FeatureMap
  module Private
    module ConfiguredCommands
      def self.github_pr_annotation
        run(Configuration::GITHUB_PR_ANNOTATION_SECTION) do |settings|
          base_metrics_path = settings['base_metrics_path'].to_s
          unless File.exist?(base_metrics_path)
            puts "Base metrics not found at '#{base_metrics_path}'. Skipping feature announcement."
            next
          end

          require 'octokit'
          client = Octokit::Client.new(access_token: required(settings, Configuration::GITHUB_PR_ANNOTATION_SECTION, 'github_token'), auto_paginate: true)
          PullRequestAnnotator.new(
            client,
            full_repo_name,
            required(settings, Configuration::GITHUB_PR_ANNOTATION_SECTION, 'pr_number'),
            base_metrics_path,
            doc_site_base_url
          ).announce
        end
      end

      def self.slack_release_log
        run(Configuration::SLACK_RELEASE_LOG_SECTION) do |settings|
          require 'octokit'
          require 'slack-ruby-client'
          ReleaseLogPublisher.new(
            required(settings, Configuration::SLACK_RELEASE_LOG_SECTION, 'github_token'),
            full_repo_name,
            display_name(settings),
            doc_site_base_url,
            main_branch,
            settings['slack_api_token'].to_s,
            settings['slack_app_user_id'].to_s,
            settings['slack_channel'].to_s,
            settings['slack_thread_parent_ts'].to_s
          ).publish
        end
      end

      def self.slack_team_notifications
        run(Configuration::SLACK_TEAM_NOTIFICATIONS_SECTION) do |settings|
          require 'octokit'
          require 'faraday'
          TeamReleaseNotifier.new(
            required(settings, Configuration::SLACK_TEAM_NOTIFICATIONS_SECTION, 'release_ref'),
            required(settings, Configuration::SLACK_TEAM_NOTIFICATIONS_SECTION, 'github_token'),
            full_repo_name,
            display_name(settings),
            (settings['teams'] || {}).transform_values(&:to_s)
          ).notify
        end
      end

      def self.run(section_name)
        settings = Private.configuration.command_sections[section_name]
        unless settings
          puts "'#{section_name}' is not configured in .feature_map/config.yml. Skipping."
          return
        end

        yield settings
      end

      def self.required(settings, section_name, key)
        value = settings[key].to_s
        raise "'#{section_name}.#{key}' must be set in .feature_map/config.yml" if value.empty?

        value
      end

      def self.display_name(settings)
        settings['display_name'].to_s.empty? ? full_repo_name.split('/').last : settings['display_name'].to_s
      end

      def self.full_repo_name
        repository_url = Private.configuration.repository['url'].to_s
        raise "'repository.url' must be set in .feature_map/config.yml" if repository_url.empty?

        URI.parse(repository_url).path.delete_prefix('/').delete_suffix('.git')
      end

      def self.main_branch
        Private.configuration.repository['main_branch'].to_s.empty? ? 'main' : Private.configuration.repository['main_branch']
      end

      def self.doc_site_base_url
        url = Private.configuration.documentation_site_url.to_s
        raise "'documentation_site_url' must be set in .feature_map/config.yml" if url.empty?

        "#{url}#/"
      end

      private_class_method :run, :required, :display_name, :full_repo_name, :main_branch, :doc_site_base_url
    end
  end
end
