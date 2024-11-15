module FeatureMap
  RSpec.describe Private::Validations::FilesHaveUniqueFeatures do
    describe 'FeatureMap.validate!' do
      context 'a file in assigned_globs has features assigned in multiple ways' do
        before do
          write_configuration

          write_file('app/services/bar/some_file.rb', <<~YML)
            # @feature Bar
          YML

          write_file('app/services/some_other_file.rb', <<~YML)
            # @feature Bar
          YML

          write_file('app/services/bar/.feature', <<~CONTENTS)
            Bar
          CONTENTS

          write_file('.features/definitions/bar.yml', <<~CONTENTS)
            name: Bar
            assigned_globs:
              - app/services/bar/**/**
          CONTENTS
        end

        it 'lets the user know that each file can only have feature assignment defined in one way' do
          expect(FeatureMap.for_file('app/missing_assignment.rb')).to eq nil
          expect { FeatureMap.validate! }.to raise_error do |e|
            expect(e).to be_a FeatureMap::InvalidFeatureMapConfigurationError
            expect(e.message).to eq <<~EXPECTED.chomp
              Feature assignment should only be defined for each file in one way. The following files have had features assigned in multiple ways.

              - app/services/bar/some_file.rb (Annotations at the top of file, Feature-specific assigned globs, Feature Assigned in .feature)

              See https://github.com/Beyond-Finance/feature_map#README.md for more details
            EXPECTED
          end
        end

        it "ignores the file with multiple feature assignments if it's not in the files param" do
          expect { FeatureMap.validate!(files: ['app/services/some_other_file.rb']) }.to_not raise_error
        end
      end

      context 'with mutliple directory assignment files' do
        before do
          write_configuration

          write_file('.features/definitions/bar.yml', <<~CONTENTS)
            name: Bar
          CONTENTS

          write_file('.features/definitions/foo.yml', <<~CONTENTS)
            name: Foo
          CONTENTS

          write_file('app/services/exciting/some_other_file.rb', <<~YML)
            class Exciting::SomeOtherFile; end
          YML

          write_file('app/services/exciting/.feature', <<~YML)
            Bar
          YML

          write_file('app/services/.feature', <<~YML)
            Foo
          YML
        end

        it 'allows multiple .feature ancestor files' do
          expect(FeatureMap.for_file('app/services/exciting/some_other_file.rb').name).to eq 'Bar'
          expect { FeatureMap.validate! }.to_not raise_error
        end
      end
    end
  end
end
