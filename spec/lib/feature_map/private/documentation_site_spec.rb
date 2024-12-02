module FeatureMap
  RSpec.describe Private::DocumentationSite do
    describe '.generate' do
      let(:feature_assignments) { { 'Bar' => ['app/lib/some_file.rb'], 'Foo' => ['app/lib/some_other_file.rb'] } }
      let(:feature_metrics) { { 'Bar' => { 'abc_size' => 12.34, 'lines_of_code' => 56, 'cyclomatic_complexity' => 7 }, 'Foo' => { 'abc_size' => 98.76, 'lines_of_code' => 543, 'cyclomatic_complexity' => 21 } } }
      let(:assets_directory) { Private::DocumentationSite.assets_directory }

      before { create_validation_artifacts }

      context 'when there is no existing site content' do
        it 'copies the HTML index page for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics)

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/index.html'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/index.html'))).to eq(File.read(File.join(assets_directory, 'index.html')))
        end

        it 'copies the JavaScript logic for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics)

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/app.js'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/app.js'))).to eq(File.read(File.join(assets_directory, 'app.js')))
        end

        it 'copies the CSS styles for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics)

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/app.css'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/app.css'))).to eq(File.read(File.join(assets_directory, 'app.css')))
        end

        it 'creates a features.js file with the appropriate feature details in the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics)

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/features.js'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/features.js'))).to eq('window.FEATURES = {"Bar":{"assignments":["app/lib/some_file.rb"],"metrics":{"abc_size":12.34,"lines_of_code":56,"cyclomatic_complexity":7}},"Foo":{"assignments":["app/lib/some_other_file.rb"],"metrics":{"abc_size":98.76,"lines_of_code":543,"cyclomatic_complexity":21}}};')
        end
      end

      context 'when a previous instance of the site content exists' do
        before do
          write_file('.feature_map/docs/index.html', '<html><body>Hello, World!</body></html>')
          write_file('.feature_map/docs/app.js', 'alert("Testing 123...")')
          write_file('.feature_map/docs/app.css', 'body { color: red; }')
          write_file('.feature_map/docs/features.js', 'window.NOT_FEATURES = {};')
        end

        it 'overwrites the HTML index page for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics)
          expect(File.read(Pathname.pwd.join('.feature_map/docs/index.html'))).to eq(File.read(File.join(assets_directory, 'index.html')))
        end

        it 'overwrites the JavaScript logic for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics)
          expect(File.read(Pathname.pwd.join('.feature_map/docs/app.js'))).to eq(File.read(File.join(assets_directory, 'app.js')))
        end

        it 'overwrites the CSS styles for the site into the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics)
          expect(File.read(Pathname.pwd.join('.feature_map/docs/app.css'))).to eq(File.read(File.join(assets_directory, 'app.css')))
        end

        it 'overwrites the features.js file with the appropriate feature details in the docs output directory' do
          Private::DocumentationSite.generate(feature_assignments, feature_metrics)
          expect(File.read(Pathname.pwd.join('.feature_map/docs/features.js'))).to eq('window.FEATURES = {"Bar":{"assignments":["app/lib/some_file.rb"],"metrics":{"abc_size":12.34,"lines_of_code":56,"cyclomatic_complexity":7}},"Foo":{"assignments":["app/lib/some_other_file.rb"],"metrics":{"abc_size":98.76,"lines_of_code":543,"cyclomatic_complexity":21}}};')
        end
      end
    end
  end
end
