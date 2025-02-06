# typed: strict
# frozen_string_literal: true

module FeatureMap
  module Private
    #
    # This class is responsible for building a release notification message that can be published to a single
    # team or to an organization as a whole. Currently, the only supported output format is Slack's Block Kit
    # (see https://app.slack.com/block-kit-builder).
    #
    class ReleaseNotificationBuilder
      extend T::Sig

      BlockKitSection = T.type_alias { T::Hash[String, T.untyped] }
      BlockKitPayload = T.type_alias { T::Array[T::Hash[String, T.untyped]] }

      class << self
        extend T::Sig

        sig { params(commits_by_feature: CommitsByFeature).returns(BlockKitPayload) }
        def build(commits_by_feature)
          return [] if commits_by_feature.empty?

          feature_names = commits_by_feature.keys.sort

          feature_names.flat_map.with_index do |feature_name, index|
            # Insert a divider between each feature but not above the first feature nor below the last feature.
            divider = index.zero? ? [] : [{ type: 'divider' }]
            divider + [build_feature_section(feature_name, T.must(commits_by_feature[feature_name]))]
          end
        end

        private

        sig { params(feature_name: String, commits: T::Array[Commit]).returns(BlockKitSection) }
        def build_feature_section(feature_name, commits)
          feature_header_markdown = "*_#{feature_name}_*"

          # If the docs site is hosted at a persistent URL, include a link to the feature show page.
          if documentation_site_url
            feature_header_markdown += " (<#{documentation_site_url}#/#{URI::DEFAULT_PARSER.escape(feature_name)}|View Documentation>)"
          end

          feature_markdown_lines = [feature_header_markdown]
          commits.each do |commit|
            commit_sub_bullet = "• #{commit.description}"

            if repository_url && commit.pull_request_number
              commit_sub_bullet += " (<#{repository_url}/pull/#{commit.pull_request_number}|##{commit.pull_request_number}>)"
            end

            feature_markdown_lines << commit_sub_bullet
          end

          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: feature_markdown_lines.join("\n")
            }
          }
        end

        sig { returns(T.nilable(String)) }
        def documentation_site_url
          Private.configuration.documentation_site_url
        end

        sig { returns(T.nilable(String)) }
        def repository_url
          Private.configuration.repository['url']
        end
      end
    end
  end
end
