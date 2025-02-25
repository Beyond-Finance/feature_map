# frozen_string_literal: true

require 'faraday'

module FeatureMap
  module Private
    # This class is responsible for all interactions with the CodeCov platform.
    class CodeCov
      CODE_COV_API_BASE_URL = 'https://api.codecov.io/api/v2/'

      class ApiError < StandardError; end
      class ConfigurationError < StandardError; end

      def self.fetch_coverage_stats(commit_sha, api_token)
        commit_details_response = fetch_commit_details(commit_sha, api_token)
        raise ApiError, "Failed to retrieve CodeCov stats for commit #{commit_sha}. Response: #{commit_details_response.status} - #{commit_details_response.body}" unless commit_details_response.success?

        build_coverage_status(commit_details_response.body)
      end

      def self.fetch_commit_details(commit_sha, api_token)
        conn.get("#{service}/#{owner}/repos/#{repo}/commits/#{commit_sha}",
                 {},
                 { 'Authorization' => "Bearer #{api_token}" })
      end

      def self.build_coverage_status(commit_details)
        file_coverage_details = commit_details.dig('report', 'files')
        raise ApiError, 'No file coverage information retruned from CodeCov.' unless file_coverage_details

        file_coverage_details.each_with_object({}) do |file_coverage, coverage_stats|
          file_path = file_coverage['name']
          file_coverage_stats = file_coverage['totals']

          next if !file_path || !file_coverage_stats

          coverage_stats[file_path] = {
            'lines' => file_coverage_stats['lines'],
            'hits' => file_coverage_stats['hits'],
            'misses' => file_coverage_stats['misses']
          }
        end
      end

      # TODO: Move these values to config.
      def self.service
        Private.configuration.code_cov['service'] ||
          (raise ConfigurationError, 'Missing CodeCov configuration: service')
      end

      def self.owner
        Private.configuration.code_cov['owner'] ||
          (raise ConfigurationError, 'Missing CodeCov configuration: owner')
      end

      def self.repo
        Private.configuration.code_cov['repo'] ||
          (raise ConfigurationError, 'Missing CodeCov configuration: repo')
      end

      def self.conn
        @conn ||= Faraday.new(url: CODE_COV_API_BASE_URL) do |f|
          f.request :json
          f.response :json
        end
      end
    end
  end
end
