# @feature Extension System
module FeatureMap
  RSpec.describe Private::DocumentationSite do
    describe '.generate' do
      let(:feature_assignments) { { 'Bar' => ['app/lib/some_file.rb'], 'Foo' => ['app/lib/some_other_file.rb'] } }
      let(:feature_metrics) { { 'Bar' => { 'abc_size' => 12.34, 'lines_of_code' => 56, 'cyclomatic_complexity' => 7 }, 'Foo' => { 'abc_size' => 98.76, 'lines_of_code' => 543, 'cyclomatic_complexity' => 21 } } }
      let(:feature_test_coverage) { { 'Bar' => { lines: 12, hits: 243, misses: 240 }, 'Foo' => 0.0 } }
      let(:feature_test_pyramid) { { 'Bar' => { unit_count: 100, unit_pending: 10, integration_count: 11, integration_pending: 4, regression_count: 7, regression_pending: 1 }, 'Foo' => nil } }
      let(:feature_additional_metrics) {
        {
          'Bar' => {
            cyclomatic_complexity: {
              percentile: 35.5, percent_of_max: 80, score: 320
            },
            encapsulation: {
              percentile: 65.2,
              percent_of_max: 75,
              score: 450
            },
            feature_size: {
              percentile: 65.2,
              percent_of_max: 75,
              score: 450
            },
            test_coverage: {
              percentile: 88,
              percent_of_max: 95,
              score: 100
            },
            health: {
              test_coverage_component: {
                awardable_points: 70,
                health_score: 66.5,
                close_to_maximum_score: true
              },
              cyclomatic_complexity_component: {
                awardable_points: 15,
                health_score: 12,
                close_to_maximum_score: true
              },
              encapsulation_component: {
                awardable_points: 15,
                health_score: 11,
                close_to_maximum_score: true
              },
              overall: 89.75
            }
          },
          'Foo' => nil
        }
      }
      let(:assets_directory) { Private::DocumentationSite.assets_directory }
      let(:configuration) { { 'foo' => 'bar' } }
      let(:git_ref) { 'main' }

      let(:expected_environment) do
        {
          git_ref: 'main'
        }
      end

      let(:expected_features) do
        {
          Bar: {
            assignments: [
              'app/lib/some_file.rb'
            ],
            metrics: {
              abc_size: 12.34,
              lines_of_code: 56,
              cyclomatic_complexity: 7
            },
            test_coverage: {
              lines: 12,
              hits: 243,
              misses: 240
            },
            test_pyramid: {
              unit_count: 100,
              unit_pending: 10,
              integration_count: 11,
              integration_pending: 4,
              regression_count: 7,
              regression_pending: 1
            },
            additional_metrics: {
              cyclomatic_complexity: {
                percentile: 35.5,
                percent_of_max: 80,
                score: 320
              },
              encapsulation: {
                percentile: 65.2,
                percent_of_max: 75,
                score: 450
              },
              feature_size: {
                percentile: 65.2,
                percent_of_max: 75,
                score: 450
              },
              test_coverage: {
                percentile: 88,
                percent_of_max: 95,
                score: 100
              },
              health: {
                test_coverage_component: {
                  awardable_points: 70,
                  health_score: 66.5,
                  close_to_maximum_score: true
                },
                cyclomatic_complexity_component: {
                  awardable_points: 15,
                  health_score: 12,
                  close_to_maximum_score: true
                },
                encapsulation_component: {
                  awardable_points: 15,
                  health_score: 11,
                  close_to_maximum_score: true
                },
                overall: 89.75
              }
            }
          },
          Foo: {
            assignments: [
              'app/lib/some_other_file.rb'
            ],
            metrics: {
              abc_size: 98.76,
              lines_of_code: 543,
              cyclomatic_complexity: 21
            },
            test_coverage: 0.0,
            test_pyramid: nil,
            additional_metrics: nil
          }
        }
      end

      let(:expected_project) do
        {
          'foo' => 'bar'
        }
      end

      let(:expected_feature_map_config) do
        {
          features: expected_features,
          environment: expected_environment,
          project: expected_project
        }
      end

      before { create_validation_artifacts }

      context 'when there is no existing site content' do
        it 'copies the HTML index page for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage, feature_test_pyramid, feature_additional_metrics, configuration, git_ref)

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/index.html'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/index.html'))).to eq(File.read(File.join(assets_directory, 'index.html')))
        end

        it 'creates a feature-map-config.js file with the appropriate feature details in the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage, feature_test_pyramid, feature_additional_metrics, configuration, git_ref)
          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to eq("window.FEATURE_MAP_CONFIG = #{expected_feature_map_config.to_json};")
        end
      end

      context 'when a previous instance of the site content exists' do
        before do
          write_file('.feature_map/docs/index.html', '<html><body>Hello, World!</body></html>')
          write_file('.feature_map/docs/feature-map-config.js', 'window.NOT_FEATURES = {};')
        end

        it 'overwrites the HTML index page for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage, feature_test_pyramid, feature_additional_metrics, configuration, git_ref)
          expect(File.read(Pathname.pwd.join('.feature_map/docs/index.html'))).to eq(File.read(File.join(assets_directory, 'index.html')))
        end

        it 'overwrites the feature-map-config.js file with the appropriate feature details in the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage, feature_test_pyramid, feature_additional_metrics, configuration, git_ref)
          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to eq("window.FEATURE_MAP_CONFIG = #{expected_feature_map_config.to_json};")
        end
      end

      context 'when features have additional details within their feature definitions' do
        before do
          description = 'The foo feature in all its glory!'
          dashboard_link = 'https://example.com/dashbords/foo'
          documentation_link = 'https://example.com/docs/foo'

          write_file('.feature_map/definitions/foo.yml', <<~CONTENTS)
            name: Foo
            description: #{description}
            dashboard_link: #{dashboard_link}
            documentation_link: #{documentation_link}
            other: abc 123
          CONTENTS

          expected_features[:Foo] = {
            description: description,
            dashboard_link: dashboard_link,
            documentation_link: documentation_link,
            assignments: [
              'app/lib/some_other_file.rb'
            ],
            metrics: {
              abc_size: 98.76,
              lines_of_code: 543,
              cyclomatic_complexity: 21
            },
            test_coverage: 0.0,
            test_pyramid: nil,
            additional_metrics: nil
          }
        end

        it 'ignores the unrelated features and excludes them from the features-map-config.js file' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage, feature_test_pyramid, feature_additional_metrics, configuration, git_ref)

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to eq("window.FEATURE_MAP_CONFIG = #{expected_feature_map_config.to_json};")
        end
      end

      context 'when features exist that are not relevant to the current application' do
        before { write_file('.feature_map/definitions/unrelated.yml', "name: Unrelated Feature\n") }

        it 'ignores the unrelated features and excludes them from the features-map-config.js file' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage, feature_test_pyramid, feature_additional_metrics, configuration, git_ref)
          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).not_to include('Unrelated Feature')
        end
      end
    end
  end
end
