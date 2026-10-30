# @feature Core Library
# frozen_string_literal: true

require 'octokit'
require 'slack-ruby-client'

module FeatureMap
  RSpec.describe Private::PullRequestAnnotator do
    subject(:annotator) { described_class.new(client, full_repo_name, pr_number, base_branch_metrics_path, doc_site_base_url) }

    let(:client) do
      instance_double(Octokit::Client,
                      pull_request_files: pr_files,
                      issue_comments: existing_comments,
                      issue: github_pr_details,
                      label: nil,
                      add_comment: nil,
                      update_comment: nil,
                      delete_comment: nil,
                      add_label: nil,
                      add_labels_to_an_issue: nil,
                      remove_label: nil)
    end
    let(:full_repo_name) { 'Beyond-Finance/glue' }
    let(:doc_site_base_url) { 'https://beyond-finance.github.io/glue/#/' }
    let(:pr_number) { 1234 }
    let(:base_branch_metrics_path) { '/tmp/base_metrics.yml' }

    let(:pr_files) do
      [
        double('File', filename: 'app/services/test_service.rb'),
        double('File', filename: 'app/services/other_test_service.rb'),
        double('File', filename: 'app/services/extra_test_service.rb')
      ]
    end
    let(:existing_comments) { [double('Comment', id: 123, body: 'Test Comment 123')] }
    let(:github_pr_details) { double('Issue', labels: existing_labels) }
    let(:existing_labels) { [double('Label', name: 'Custom Label')] }
    let(:first_impacted_feature) { CodeFeatures::Feature.from_hash('name' => 'Program Management') }
    let(:second_impacted_feature) { CodeFeatures::Feature.from_hash('name' => 'Onboarding') }
    let(:third_impacted_feature) { CodeFeatures::Feature.from_hash('name' => 'Enrollment Agreements') }

    before do
      allow(annotator).to receive(:puts)
      allow(FeatureMap).to receive(:for_file).and_return(first_impacted_feature, second_impacted_feature, third_impacted_feature)
    end

    describe '#announce' do
      it 'retrieves the set of files for the specified pull request from Github' do
        annotator.announce
        expect(client).to have_received(:pull_request_files).with(full_repo_name, pr_number)
      end

      context 'when no features are impacted by the pull request' do
        before { allow(FeatureMap).to receive(:for_file).and_return(nil) }

        context 'when no existing comment is found' do
          it 'does not create a comment on the pull request' do
            annotator.announce
            expect(client).not_to have_received(:add_comment)
          end
        end

        context 'when an existing comment is found' do
          let(:existing_comments) do
            [double('Comment', id: 987, body: '<!-- FEATURE_ANALYSIS_COMMENT --> Existing Feature Annotator Comment')]
          end

          it 'deletes the existing comment on the pull request' do
            annotator.announce
            expect(client).to have_received(:delete_comment).with(full_repo_name, existing_comments.first.id)
          end
        end

        context 'when existing feature labels are assigned to the pull request' do
          let(:existing_labels) { [double('Label', name: 'Feature Authentication')] }

          it 'removes the existing feature labels' do
            annotator.announce
            expect(client).to have_received(:remove_label).with(full_repo_name, pr_number,
                                                                existing_labels.first.name)
          end
        end

        context 'when no feature labels are assigned to the pull request' do
          it 'does not create or remove any labels' do
            annotator.announce
            expect(client).not_to have_received(:add_labels_to_an_issue)
            expect(client).not_to have_received(:remove_label)
          end
        end
      end

      context 'when features are impacted by the pull request' do
        context 'when no existing comment is found' do
          it 'creates a comment on the pull request' do
            annotator.announce
            expect(client).to have_received(:add_comment) do |*args|
              expect(args[0]).to eq(full_repo_name)
              expect(args[1]).to eq(pr_number)
              expect(args[2]).to start_with('<!-- FEATURE_ANALYSIS_COMMENT -->')
              expect(args[2]).to include(first_impacted_feature.name)
              expect(args[2]).to include(second_impacted_feature.name)
              expect(args[2]).to include(third_impacted_feature.name)
            end
          end
        end

        context 'when an existing comment is found' do
          let(:existing_comments) do
            [double('Comment', id: 987, body: '<!-- FEATURE_ANALYSIS_COMMENT --> Existing Feature Annotator Comment')]
          end

          it 'updates the existing comment on the pull request' do
            annotator.announce
            expect(client).to have_received(:update_comment) do |*args|
              expect(args[0]).to eq(full_repo_name)
              expect(args[1]).to eq(existing_comments.first.id)
              expect(args[2]).to start_with('<!-- FEATURE_ANALYSIS_COMMENT -->')
              expect(args[2]).to include(first_impacted_feature.name)
              expect(args[2]).to include(second_impacted_feature.name)
              expect(args[2]).to include(third_impacted_feature.name)
            end
          end
        end

        context 'when existing feature labels are assigned to the pull request' do
          let(:existing_labels) { [double('Label', name: 'Feature Authentication')] }

          it 'removes the labels for any features no longer impacted by the pull request' do
            annotator.announce
            expect(client).to have_received(:remove_label).with(full_repo_name, pr_number,
                                                                existing_labels.first.name)
          end

          it 'creates labels for any features that are newly impacted by the pull request' do
            annotator.announce
            expect(client).to have_received(:add_labels_to_an_issue).with(full_repo_name, pr_number,
                                                                          [first_impacted_feature.label])
            expect(client).to have_received(:add_labels_to_an_issue).with(full_repo_name, pr_number,
                                                                          [second_impacted_feature.label])
            expect(client).to have_received(:add_labels_to_an_issue).with(full_repo_name, pr_number,
                                                                          [third_impacted_feature.label])
          end

          context 'when the existing feature label is still an impacted feature' do
            let(:existing_labels) do
              [
                double('Label', name: first_impacted_feature.label),
                double('Label', name: second_impacted_feature.label),
                double('Label', name: third_impacted_feature.label)
              ]
            end

            it 'leavels the label in place' do
              annotator.announce
              expect(client).not_to have_received(:add_labels_to_an_issue)
              expect(client).not_to have_received(:remove_label)
            end
          end
        end

        context 'when no feature labels are assigned to the pull request' do
          let(:existing_labels) { [] }

          it 'creates labels for all features impacted by the pull request' do
            annotator.announce
            expect(client).to have_received(:add_labels_to_an_issue).with(full_repo_name, pr_number,
                                                                          [first_impacted_feature.label])
            expect(client).to have_received(:add_labels_to_an_issue).with(full_repo_name, pr_number,
                                                                          [second_impacted_feature.label])
            expect(client).to have_received(:add_labels_to_an_issue).with(full_repo_name, pr_number,
                                                                          [third_impacted_feature.label])
          end
        end
      end
    end
  end
end
