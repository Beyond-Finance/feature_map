module FeatureMap
  RSpec.describe Private::DocumentationSite do
    describe '.generate' do
      let(:feature_assignments) { { 'Bar' => ['app/lib/some_file.rb'], 'Foo' => ['app/lib/some_other_file.rb'] } }
      let(:feature_metrics) { { 'Bar' => { 'abc_size' => 12.34, 'lines_of_code' => 56, 'cyclomatic_complexity' => 7 }, 'Foo' => { 'abc_size' => 98.76, 'lines_of_code' => 543, 'cyclomatic_complexity' => 21 } } }
      let(:feature_test_coverage) { { 'Bar' => { lines: 12, hits: 243, misses: 240 }, 'Foo' => 0.0 } }
      let(:assets_directory) { Private::DocumentationSite.assets_directory }

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
            test_coverage: 0.0
          }
        }
      end

      let(:expected_environment) do
        {
          GITHUB_SHA_URL: nil
        }
      end

      let(:expected_feature_map_config) do
        {
          features: expected_features,
          environment: expected_environment
        }
      end

      before { create_validation_artifacts }

      context 'when there is no existing site content' do
        it 'copies the HTML index page for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage)

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/index.html'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/index.html'))).to eq(File.read(File.join(assets_directory, 'index.html')))
        end

        it 'creates a feature-map-config.js file with the appropriate feature details in the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage)

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to eq("window.FEATURE_MAP_CONFIG = #{expected_feature_map_config.to_json};")
        end

        it 'includes environment variables when available' do
          stub_const('ENV', ENV.to_h.merge('CIRCLE_REPOSITORY_URL' => 'git@github.com:Beyond-Finance/glue.git', 'CIRCLE_SHA1' => 'abcd'))

          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage)

          expected_feature_map_config[:environment][:GITHUB_SHA_URL] = 'https://github.com/Beyond-Finance/glue/blob/abcd'

          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to eq("window.FEATURE_MAP_CONFIG = #{expected_feature_map_config.to_json};")
        end
      end

      context 'when a previous instance of the site content exists' do
        before do
          write_file('.feature_map/docs/index.html', '<html><body>Hello, World!</body></html>')
          write_file('.feature_map/docs/feature-map-config.js', 'window.NOT_FEATURES = {};')
        end

        it 'overwrites the HTML index page for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage)
          expect(File.read(Pathname.pwd.join('.feature_map/docs/index.html'))).to eq(File.read(File.join(assets_directory, 'index.html')))
        end

        it 'overwrites the feature-map-config.js file with the appropriate feature details in the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage)
          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to eq("window.FEATURE_MAP_CONFIG = #{expected_feature_map_config.to_json};")
        end

        it 'includes environment variables when available' do
          stub_const('ENV', ENV.to_h.merge('CIRCLE_REPOSITORY_URL' => 'https://github.com/Beyond-Finance/glue.git', 'CIRCLE_SHA1' => 'abcd'))

          Private::DocumentationSite.generate(feature_assignments, feature_metrics, feature_test_coverage)

          expected_feature_map_config[:environment][:GITHUB_SHA_URL] = 'https://github.com/Beyond-Finance/glue/blob/abcd'

          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to eq("window.FEATURE_MAP_CONFIG = #{expected_feature_map_config.to_json};")
        end
      end
    end
  end
end
