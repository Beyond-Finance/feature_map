module FeatureMap
  RSpec.describe Private::AssignmentMappers::FeatureGlobs do
    before { write_configuration }

    describe 'FeatureMap.for_file' do
      before do
        write_file('.features/definitions/bar.yml', <<~CONTENTS)
          name: Bar
          assigned_globs:
            - app/services/bar_stuff/**/**
        CONTENTS

        write_file('app/services/bar_stuff/thing.rb')
        write_file('app/services/bar_stuff/[test]/thing.rb')
      end

      it 'can find the assigned feature of files in assigned_globs' do
        expect(FeatureMap.for_file('app/services/bar_stuff/thing.rb').name).to eq 'Bar'
        expect(FeatureMap.for_file('app/services/bar_stuff/[test]/thing.rb').name).to eq 'Bar'
      end
    end

    describe 'FeatureMap.validate!' do
      context 'two features are assigned the same exact glob' do
        before do
          write_configuration

          write_file('packs/my_pack/assigned_file.rb')
          write_file('frontend/javascripts/blah/my_file.rb')
          write_file('frontend/javascripts/blah/subdir/my_file.rb')

          write_file('.features/definitions/bar.yml', <<~CONTENTS)
            name: Bar
            assigned_globs:
              - packs/**/**
              - frontend/javascripts/blah/subdir/my_file.rb
          CONTENTS

          write_file('.features/definitions/foo.yml', <<~CONTENTS)
            name: Foo
            assigned_globs:
              - packs/**/**
              - frontend/javascripts/blah/**/**
          CONTENTS
        end

        it 'lets the user know that `assigned_globs` can not overlap' do
          expect { FeatureMap.validate! }.to raise_error do |e|
            expect(e).to be_a FeatureMap::InvalidFeatureMapConfigurationError
            expect(e.message).to eq <<~EXPECTED.chomp
              `assigned_globs` cannot overlap between features. The following globs overlap:

              - `packs/**/**` (from `.features/definitions/bar.yml`), `packs/**/**` (from `.features/definitions/foo.yml`)
              - `frontend/javascripts/blah/subdir/my_file.rb` (from `.features/definitions/bar.yml`), `frontend/javascripts/blah/**/**` (from `.features/definitions/foo.yml`)

              See https://github.com/Beyond-Finance/feature_map#README.md for more details
            EXPECTED
          end
        end
      end
    end
  end
end
