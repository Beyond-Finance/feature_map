# @feature Testing Tools
# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::CodeCov do
    let(:commit_sha) { '1234567890abcdef1234567890abcdef' }
    let(:api_token) { 'e5124eb5-c948-4136-9297-08efa6f2d537' }
    let(:code_cov_service) { 'github' }
    let(:code_cov_owner) { 'Acme-Org' }
    let(:code_cov_repo) { 'sample_app' }
    let(:code_cov_request) do
      stub_request(:get, "https://api.codecov.io/api/v2/#{code_cov_service}/#{code_cov_owner}/repos/#{code_cov_repo}/commits/#{commit_sha}")
        .with(headers: { 'Authorization' => "Bearer #{api_token}" })
    end
    let(:code_cov_response) do
      {
        report: {
          files: [
            { name: 'app/my_error.rb', totals: { lines: 10, hits: 8, misses: 2, other: 123 } },
            { name: 'app/lib/other.rb', totals: { lines: 9, hits: 3, misses: 6 } }
          ]
        }
      }
    end

    before { write_configuration('code_cov' => { 'service' => code_cov_service, 'owner' => code_cov_owner, 'repo' => code_cov_repo }) }

    describe '.fetch_coverage_stats' do
      context 'when the CodeCov API returns an error response' do
        before { code_cov_request.to_return(status: 500, body: { error: 'Internal Server Error' }.to_json, headers: { 'Content-Type' => 'application/json' }) }

        it 'raises an error' do
          expect { described_class.fetch_coverage_stats(commit_sha, api_token) }.to raise_error(described_class::ApiError, /500 - \{"error"=>"Internal Server Error"\}/i)
        end
      end

      context 'when the CodeCov API returns a success response' do
        before { code_cov_request.to_return(status: 200, body: code_cov_response.to_json, headers: { 'Content-Type' => 'application/json' }) }

        it 'retrieves test coverage statistics from CodeCov for the specified commit' do
          described_class.fetch_coverage_stats(commit_sha, api_token)
          expect(code_cov_request).to have_been_requested
        end

        it 'isolates the returned coverage statistics to only the relevant metrics for each file returned from CodeCov' do
          coverage_stats = described_class.fetch_coverage_stats(commit_sha, api_token)
          expect(coverage_stats).to match({
                                            'app/my_error.rb' => { 'lines' => 10, 'hits' => 8, 'misses' => 2 },
                                            'app/lib/other.rb' => { 'lines' => 9, 'hits' => 3, 'misses' => 6 }
                                          })
        end

        context 'when the CodeCov API returns no file coverage details' do
          let(:code_cov_response) { { report: { test: 123 } } }

          it 'raises an error' do
            expect { described_class.fetch_coverage_stats(commit_sha, api_token) }.to raise_error(described_class::ApiError, /No file coverage information retruned/i)
          end
        end

        context 'when an file entry in the CodeCov API has no coverage details' do
          let(:code_cov_response) { { report: { files: [{ name: 'app/test_file.rb' }] } } }

          it 'gracefully ignores that file' do
            expect(described_class.fetch_coverage_stats(commit_sha, api_token)).to eq({})
          end
        end

        context 'when no CodeCov service is configured' do
          before { write_configuration('code_cov' => { 'service' => nil, 'owner' => code_cov_owner, 'repo' => code_cov_repo }) }

          it 'raises an error' do
            expect { described_class.fetch_coverage_stats(commit_sha, api_token) }.to raise_error(described_class::ConfigurationError, 'Missing CodeCov configuration: service')
          end
        end

        context 'when no CodeCov owner is configured' do
          before { write_configuration('code_cov' => { 'service' => code_cov_service, 'owner' => nil, 'repo' => code_cov_repo }) }

          it 'raises an error' do
            expect { described_class.fetch_coverage_stats(commit_sha, api_token) }.to raise_error(described_class::ConfigurationError, 'Missing CodeCov configuration: owner')
          end
        end

        context 'when no CodeCov repo is configured' do
          before { write_configuration('code_cov' => { 'service' => code_cov_service, 'owner' => code_cov_owner, 'repo' => nil }) }

          it 'raises an error' do
            expect { described_class.fetch_coverage_stats(commit_sha, api_token) }.to raise_error(described_class::ConfigurationError, 'Missing CodeCov configuration: repo')
          end
        end
      end
    end
  end
end
