# @feature Extension System
module FeatureMap
  # TODO: This was failing without cache busting. It seems like the code_ownership gem has some
  # interdependencies within their tests that were not replicated into this gem and seem undesirable.
  # For the time being, I've added explicit cache busting to this test to work around this.
  # We do not bust the cache here so that we only load the extension once!
  RSpec.describe Private::ExtensionLoader, :do_not_bust_cache do
    before do
      FeatureMap.bust_caches!
      FeatureMap::CodeFeatures.bust_caches!
      write_configuration('require' => ['./lib/my_extension.rb'])

      write_file('.feature_map/definitions/bar.yml', <<~CONTENTS)
        name: Bar
      CONTENTS

      write_file('app/services/my_assignable_file.rb')

      write_file('lib/my_extension.rb', <<~RUBY)
        class MyExtension
          include FeatureMap::Mapper
          include FeatureMap::Validator

          def map_file_to_feature(file)
            FeatureMap::CodeFeatures.all.last
          end

          def globs_to_feature(files)
            Dir.glob('**/*.rb').map{|f| [f, FeatureMap::CodeFeatures.all.last]}.to_h
          end

          def description
            'My special extension'
          end

          def validation_errors(files:, autocorrect: true, stage_changes: true)
            ['my validation errors']
          end

          def bust_caches!
            nil
          end
        end
      RUBY
    end

    after(:all) do
      validators_without_extension = Validator.instance_variable_get(:@validators).reject { |v| v == MyExtension }
      Validator.instance_variable_set(:@validators, validators_without_extension)
      mappers_without_extension = Mapper.instance_variable_get(:@mappers).reject { |v| v == MyExtension }
      Mapper.instance_variable_set(:@mappers, mappers_without_extension)
    end

    describe 'FeatureMap.validate!' do
      it 'allows third party validations to be injected' do
        expect { FeatureMap.validate! }.to raise_error do |e|
          expect(e).to be_a FeatureMap::InvalidFeatureMapConfigurationError
          expect(e.message).to eq <<~EXPECTED.chomp
            my validation errors
            See https://github.com/Beyond-Finance/feature_map#README.md for more details
          EXPECTED
        end
      end

      it 'allows extensions to add to the features file' do
        expect { FeatureMap.validate! }.to raise_error(FeatureMap::InvalidFeatureMapConfigurationError)
        expect(assignments_file_path.read).to eq <<~EXPECTED
          # STOP! - DO NOT EDIT THIS FILE MANUALLY
          # This file was automatically generated by "bin/featuremap validate". The next time this file
          # is generated any changes will be lost. For more details:
          # https://github.com/Beyond-Finance/feature_map
          #
          # It is recommended to commit this file into your source control. It will only change when the
          # set of files assigned to a feature change, which should be explicitly tracked.

          ---
          files:
            ".feature_map/definitions/bar.yml":
              feature: Bar
              mapper: Feature definition file assignment
            app/services/my_assignable_file.rb:
              feature: Bar
              mapper: My special extension
            lib/my_extension.rb:
              feature: Bar
              mapper: My special extension
          features:
            Bar:
              files:
              - ".feature_map/definitions/bar.yml"
              - app/services/my_assignable_file.rb
              - lib/my_extension.rb
        EXPECTED
      end
    end
  end
end
