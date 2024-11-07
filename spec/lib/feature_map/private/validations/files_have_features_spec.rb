module FeatureMap
  RSpec.describe Private::Validations::FilesHaveFeatures do
    describe 'FeatureMap.validate!' do
      context 'input files are not part of configured assigned_globs' do
        before do
          write_file('Gemfile', '')

          write_configuration
        end

        it 'does not raise an error' do
          expect { FeatureMap.validate!(files: ['Gemfile']) }.to_not raise_error
        end
      end

      context 'a file in assigned_globs does not have a feature' do
        before do
          write_file('app/missing_assignment.rb', '')

          write_file('app/some_other_file.rb', <<~CONTENTS)
            # @feature Bar
          CONTENTS

          write_file('config/features/bar.yml', <<~CONTENTS)
            name: Bar
          CONTENTS
        end

        context 'the file is not in unassigned_globs' do
          before do
            write_configuration
          end

          it 'lets the user know the file must have a feature assignment' do
            expect { FeatureMap.validate! }.to raise_error do |e|
              expect(e).to be_a FeatureMap::InvalidFeatureMapConfigurationError
              expect(e.message).to eq <<~EXPECTED.chomp
                Some files are missing a feature assignment:

                - app/missing_assignment.rb

                See https://github.com/Beyond-Finance/feature_map#README.md for more details
              EXPECTED
            end
          end

          context 'the input files do not include the file missing a feature assignment' do
            it 'ignores the file missing a feature assignment' do
              expect { FeatureMap.validate!(files: ['app/some_other_file.rb']) }.to_not raise_error
            end
          end
        end

        context 'that file is in unassigned_globs' do
          before do
            write_configuration('unassigned_globs' => ['app/missing_assignment.rb', 'config/feature_map.yml'])
          end

          it 'does not raise an error' do
            expect { FeatureMap.validate! }.to_not raise_error
          end
        end
      end

      context 'many files in assigned_globs do not have a feature assigned' do
        before do
          write_configuration

          500.times do |i|
            write_file("app/missing_assignment#{i}.rb", '')
          end
        end

        it 'lets the user know that each file must have a feature assigned' do
          expect { FeatureMap.validate! }.to raise_error do |e|
            expect(e).to be_a FeatureMap::InvalidFeatureMapConfigurationError
            expect(e.message).to include 'Some files are missing a feature assignment:'
            500.times do |i|
              expect(e.message).to include "- app/missing_assignment#{i}.rb"
            end
          end
        end
      end
    end
  end
end
