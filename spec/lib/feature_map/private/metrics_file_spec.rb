module FeatureMap
  RSpec.describe Private::MetricsFile do
    describe '.write!' do
      let(:expected_file) do
        <<~FEATURES
          # STOP! - DO NOT EDIT THIS FILE MANUALLY
          # This file was automatically generated by "bin/featuremap validate". The next time this file
          # is generated any changes will be lost. For more details:
          # https://github.com/Beyond-Finance/feature_map
          #
          # It is NOT recommended to commit this file into your source control. It will change as a
          # result of nearly all other source code changes. This file should be ignored by your source
          # control but can be used for other feature analysis operations (e.g. documentation
          # generation, etc).

          ---
          features:
            Bar:
              abc_size: 1.0
              cyclomatic_complexity: 1
              lines_of_code: 6
              todo_locations: {}
              complexity_ratio: 6.0
              encapsulation_ratio: 0.3333333333333333
            Foo:
              abc_size: 2.0
              cyclomatic_complexity: 1
              lines_of_code: 7
              todo_locations: {}
              complexity_ratio: 7.0
              encapsulation_ratio: 0.2857142857142857
            Empty Feature:
              abc_size: 0
              cyclomatic_complexity: 0
              lines_of_code: 1
              todo_locations: {}
              complexity_ratio: 0.0
              encapsulation_ratio: 1.0
        FEATURES
      end

      before do
        # Must use the skip_features_validation to avoid having the GlobCache loaded from the stub assignments.yml file.
        write_configuration('skip_features_validation' => true)
        create_files_with_defined_classes
        write_file('.feature_map/definitions/empty.yml', <<~CONTENTS)
          name: Empty Feature
        CONTENTS
      end

      context 'when NO metrics.yml file exists' do
        it 'overwrites the metrics.yml file with a new set of feature assignment' do
          expect(File.exist?(Private::MetricsFile.path)).to be_falsey
          Private::MetricsFile.write!
          expect(File.read(Private::MetricsFile.path)).to eq(expected_file)
        end
      end

      context 'an existing metrics.yml file exists' do
        before do
          write_file('.feature_map/metrics.yml', <<~CONTENTS)
            # Placeholder to be removed by test.
            ---
            foo: 123
          CONTENTS
        end

        it 'overwrites the metrics.yml file with a new set of feature assignment' do
          expect(File.read(Private::MetricsFile.path)).not_to eq(expected_file)
          Private::MetricsFile.write!
          expect(File.read(Private::MetricsFile.path)).to eq(expected_file)
        end
      end
    end

    describe '.path' do
      it 'returns the path to the metrics.yml file' do
        # Expects path to be something like: /private/var/folders/6d/.../metrics.yml
        expect(Private::MetricsFile.path.to_s).to match(%r{/[a-zA-Z0-9-/]+/.feature_map/metrics\.yml})
      end
    end

    describe '.load_features!' do
      before { create_validation_artifacts }

      it 'returns the feature metrics details from the existing Metrics File' do
        expect(Private::MetricsFile.load_features!).to eq({
                                                            'Bar' => {
                                                              'abc_size' => 12.34,
                                                              'lines_of_code' => 56,
                                                              'cyclomatic_complexity' => 7
                                                            }
                                                          })
      end

      it 'raises an error if the file does not contain any features content' do
        write_file('.feature_map/metrics.yml', <<~CONTENTS)
          ---
          files:
            app/lib/foo.rb:
              abc_size: 12.34
              lines_of_code: 56
              cyclomatic_complexity: 7
        CONTENTS

        expect { Private::MetricsFile.load_features! }.to raise_error(Private::MetricsFile::FileContentError, /Unexpected content found/i)
      end

      it 'raises an error if the file does not contain an object' do
        write_file('.feature_map/metrics.yml', 'Test 1234')

        expect { Private::MetricsFile.load_features! }.to raise_error(Private::MetricsFile::FileContentError, /Unexpected content found/i)
      end

      it 'raises an error if the file contains invalid YAML' do
        write_file('.feature_map/metrics.yml', <<~CONTENTS)
          ---
          files:
            app/lib/foo.rb:
                abc_size: 12.34
              lines_of_code: 56
              cyclomatic_complexity: 7
        CONTENTS

        expect { Private::MetricsFile.load_features! }.to raise_error(Private::MetricsFile::FileContentError, /Invalid YAML content/i)
      end

      it 'raises an error if the file is not found' do
        File.delete('.feature_map/metrics.yml')

        expect { Private::MetricsFile.load_features! }.to raise_error(Private::MetricsFile::FileContentError, /No feature metrics file found/i)
      end
    end
  end
end
