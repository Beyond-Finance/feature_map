module FeatureMap
  RSpec.describe Private::FeaturesFile do
    describe '.actual_contents_lines' do
      it 'returns an array of files from the existing FEATURES.yml file' do
        write_file('FEATURES.yml', <<~YML)
          # STOP! - DO NOT EDIT THIS FILE MANUALLY
          # This file was automatically generated by "bin/featuremap validate". The next time this file
          # is generated any changes will be lost. For more details:
          # https://github.com/Beyond-Finance/feature_map

          ---
          files:
            app/services/my_assignable_file.rb:
              feature: Bar
              mapper: Annotations at the top of file
            config/features/bar.yml:
              feature: Bar
              mapper: Feature YML assignment
            config/features/foo.yml:
              feature: Foo
              mapper: Feature YML assignment
            lib/foo_logic.rb:
              feature: Foo
              mapper: Feature Assigned in .feature
          features:
            Bar:
              files:
              - app/services/my_assignable_file.rb
              - config/features/bar.yml
            Foo:
              files:
              - config/features/foo.yml
              - lib/foo_logic.rb
        YML

        expect(Private::FeaturesFile.actual_contents_lines).to eq([
                                                                    '# STOP! - DO NOT EDIT THIS FILE MANUALLY',
                                                                    '# This file was automatically generated by "bin/featuremap validate". The next time this file',
                                                                    '# is generated any changes will be lost. For more details:',
                                                                    '# https://github.com/Beyond-Finance/feature_map',
                                                                    '',
                                                                    '---',
                                                                    'files:',
                                                                    '  app/services/my_assignable_file.rb:',
                                                                    '    feature: Bar',
                                                                    '    mapper: Annotations at the top of file',
                                                                    '  config/features/bar.yml:',
                                                                    '    feature: Bar',
                                                                    '    mapper: Feature YML assignment',
                                                                    '  config/features/foo.yml:',
                                                                    '    feature: Foo',
                                                                    '    mapper: Feature YML assignment',
                                                                    '  lib/foo_logic.rb:',
                                                                    '    feature: Foo',
                                                                    '    mapper: Feature Assigned in .feature',
                                                                    'features:',
                                                                    '  Bar:',
                                                                    '    files:',
                                                                    '    - app/services/my_assignable_file.rb',
                                                                    '    - config/features/bar.yml',
                                                                    '  Foo:',
                                                                    '    files:',
                                                                    '    - config/features/foo.yml',
                                                                    '    - lib/foo_logic.rb',
                                                                    ''
                                                                  ])
      end

      context 'when NO FEATURES.yml file exists' do
        it 'returns an array with a single empty string' do
          expect(Private::FeaturesFile.actual_contents_lines).to eq([''])
        end
      end
    end

    describe '.expected_contents_lines' do
      context 'when files are assigned using multiple mappers' do
        before { create_non_empty_application }

        it 'generates the expected content' do
          expect(Private::FeaturesFile.expected_contents_lines).to eq([
                                                                        '# STOP! - DO NOT EDIT THIS FILE MANUALLY',
                                                                        '# This file was automatically generated by "bin/featuremap validate". The next time this file',
                                                                        '# is generated any changes will be lost. For more details:',
                                                                        '# https://github.com/Beyond-Finance/feature_map',
                                                                        '',
                                                                        '---',
                                                                        'files:',
                                                                        '  frontend/javascripts/packages/my_package/assigned_file.jsx:',
                                                                        '    feature: Bar',
                                                                        '    mapper: Annotations at the top of file',
                                                                        '  packs/my_pack/assigned_file.rb:',
                                                                        '    feature: Bar',
                                                                        '    mapper: Annotations at the top of file',
                                                                        '  app/services/bar_stuff/**:',
                                                                        '    feature: Bar',
                                                                        '    mapper: Feature-specific assigned globs',
                                                                        '  frontend/javascripts/bar_stuff/**:',
                                                                        '    feature: Bar',
                                                                        '    mapper: Feature-specific assigned globs',
                                                                        '  directory/my_feature/**/**:',
                                                                        '    feature: Bar',
                                                                        '    mapper: Feature Assigned in .feature',
                                                                        '  config/features/bar.yml:',
                                                                        '    feature: Bar',
                                                                        '    mapper: Feature YML assignment',
                                                                        'features:',
                                                                        '  Bar:',
                                                                        '    files:',
                                                                        '    - app/services/bar_stuff/**',
                                                                        '    - config/features/bar.yml',
                                                                        '    - directory/my_feature/**/**',
                                                                        '    - frontend/javascripts/bar_stuff/**',
                                                                        '    - frontend/javascripts/packages/my_package/assigned_file.jsx',
                                                                        '    - packs/my_pack/assigned_file.rb',
                                                                        '    total_lines: 8',
                                                                        '    abc_size: 0',
                                                                        ''
                                                                      ])
        end
      end

      context 'when multiple features are assigned to files' do
        before { create_files_with_defined_classes }

        it 'generates the expected content' do
          expect(Private::FeaturesFile.expected_contents_lines).to eq([
                                                                        '# STOP! - DO NOT EDIT THIS FILE MANUALLY',
                                                                        '# This file was automatically generated by "bin/featuremap validate". The next time this file',
                                                                        '# is generated any changes will be lost. For more details:',
                                                                        '# https://github.com/Beyond-Finance/feature_map',
                                                                        '',
                                                                        '---',
                                                                        'files:',
                                                                        '  app/my_error.rb:',
                                                                        '    feature: Bar',
                                                                        '    mapper: Annotations at the top of file',
                                                                        '  app/my_file.rb:',
                                                                        '    feature: Foo',
                                                                        '    mapper: Annotations at the top of file',
                                                                        '  config/features/bar.yml:',
                                                                        '    feature: Bar',
                                                                        '    mapper: Feature YML assignment',
                                                                        '  config/features/foo.yml:',
                                                                        '    feature: Foo',
                                                                        '    mapper: Feature YML assignment',
                                                                        'features:',
                                                                        '  Bar:',
                                                                        '    files:',
                                                                        '    - app/my_error.rb',
                                                                        '    - config/features/bar.yml',
                                                                        '    total_lines: 8',
                                                                        '    abc_size: 1.0',
                                                                        '  Foo:',
                                                                        '    files:',
                                                                        '    - app/my_file.rb',
                                                                        '    - config/features/foo.yml',
                                                                        '    total_lines: 10',
                                                                        '    abc_size: 2.0',
                                                                        ''
                                                                      ])
        end
      end
    end

    describe '.write!' do
      let(:expected_file) do
        <<~FEATURES
          # STOP! - DO NOT EDIT THIS FILE MANUALLY
          # This file was automatically generated by "bin/featuremap validate". The next time this file
          # is generated any changes will be lost. For more details:
          # https://github.com/Beyond-Finance/feature_map

          ---
          files:
            config/features/foo.yml:
              feature: Foo
              mapper: Feature YML assignment
          features:
            Foo:
              files:
              - config/features/foo.yml
              total_lines: 1
              abc_size: 0
        FEATURES
      end

      before do
        # Must use the skip_features_validation to avoid having the GlobCache loaded from the stub FEATURES.yml file.
        write_configuration('skip_features_validation' => true)
        write_file('config/features/foo.yml', <<~CONTENTS)
          name: Foo
        CONTENTS
      end

      context 'when NO FEATURES.yml file exists' do
        it 'overwrites the FEATURES.yml file with a new set of feature assignment' do
          expect(File.exist?(Private::FeaturesFile.path)).to be_falsey
          Private::FeaturesFile.write!
          expect(File.read(Private::FeaturesFile.path)).to eq(expected_file)
        end
      end

      context 'an existing FEATURES.yml file exists' do
        before do
          write_file('FEATURES.yml', <<~CONTENTS)
            # Placeholder to be removed by test.
            ---
            foo: 123
          CONTENTS
        end

        it 'overwrites the FEATURES.yml file with a new set of feature assignment' do
          expect(File.read(Private::FeaturesFile.path)).not_to eq(expected_file)
          Private::FeaturesFile.write!
          expect(File.read(Private::FeaturesFile.path)).to eq(expected_file)
        end
      end
    end

    describe '.path' do
      it 'returns the path to the FEATURES.yml file' do
        # Expects path to be something like: /private/var/folders/6d/qkn6zt_s1lzdx5pzr5bdln3c0000gn/T/rspec-5704120241108-57041-1f72z8/FEATURES.yml
        expect(Private::FeaturesFile.path.to_s).to match(%r{/[a-zA-Z0-9-/]+/FEATURES\.yml})
      end
    end

    describe '.use_features_cache?' do
      let(:skip_features_validation) { false }

      before do
        write_configuration('skip_features_validation' => skip_features_validation)
        write_file('FEATURES.yml', <<~CONTENTS)
          ---
          files: {}
          features: {}
        CONTENTS
      end

      it 'returns true when the features cache should be used' do
        expect(Private::FeaturesFile.use_features_cache?).to eq(true)
      end

      context 'when NO FEATURES.yml file exists' do
        before { features_file_path.delete }

        it 'returns false' do
          expect(Private::FeaturesFile.use_features_cache?).to eq(false)
        end
      end

      context 'when the skip_features_validation configuration setting is set' do
        let(:skip_features_validation) { true }

        it 'returns false' do
          expect(Private::FeaturesFile.use_features_cache?).to eq(false)
        end
      end
    end

    describe '.to_glob_cache' do
      context 'when the FEATURES.yml file contains no feature mappings' do
        before do
          write_configuration
          write_file('FEATURES.yml', <<~CONTENTS)
            ---
            files: {}
            features: {}
          CONTENTS
        end

        it 'initializes an empty GlobCache' do
          glob_cache = Private::FeaturesFile.to_glob_cache
          expect(glob_cache).to be_a(Private::GlobCache)
          expect(glob_cache.raw_cache_contents).to eq({})
        end
      end

      context 'when the FEATURES.yml file contains features assigned using multiple mappers' do
        before do
          write_configuration

          write_file('config/features/bar.yml', <<~CONTENTS)
            name: Bar
          CONTENTS

          write_file('FEATURES.yml', <<~CONTENTS)
            # STOP! - DO NOT EDIT THIS FILE MANUALLY
            # This file was automatically generated by "bin/featuremap validate". The next time this file
            # is generated any changes will be lost. For more details:
            # https://github.com/Beyond-Finance/feature_map

            ---
            files:
              frontend/javascripts/packages/my_package/assigned_file.jsx:
                feature: Bar
                mapper: Annotations at the top of file
              packs/my_pack/assigned_file.rb:
                feature: Bar
                mapper: Annotations at the top of file
              app/services/bar_stuff/**:
                feature: Bar
                mapper: Feature-specific assigned globs
              frontend/javascripts/bar_stuff/**:
                feature: Bar
                mapper: Feature-specific assigned globs
              directory/my_feature/**/**:
                feature: Bar
                mapper: Feature Assigned in .feature
              config/features/bar.yml:
                feature: Bar
                mapper: Feature YML assignment
            features:
              Bar:
                files:
                - app/services/bar_stuff/**
                - config/features/bar.yml
                - directory/my_feature/**/**
                - frontend/javascripts/bar_stuff/**
                - frontend/javascripts/packages/my_package/assigned_file.jsx
                - packs/my_pack/assigned_file.rb
          CONTENTS
        end

        it 'initializes the glob cache properly from the FEATURES.yml file' do
          glob_cache = Private::FeaturesFile.to_glob_cache
          expect(glob_cache).to be_a(Private::GlobCache)
          expect(glob_cache.raw_cache_contents.keys).to eq(['Annotations at the top of file', 'Feature-specific assigned globs', 'Feature Assigned in .feature', 'Feature YML assignment'])
          expect(glob_cache.raw_cache_contents['Annotations at the top of file'].length).to eq(2)
          expect(glob_cache.raw_cache_contents['Annotations at the top of file']).to eq(
            'frontend/javascripts/packages/my_package/assigned_file.jsx' => CodeFeatures.find('Bar'),
            'packs/my_pack/assigned_file.rb' => CodeFeatures.find('Bar')
          )
          expect(glob_cache.raw_cache_contents['Feature-specific assigned globs'].length).to eq(2)
          expect(glob_cache.raw_cache_contents['Feature-specific assigned globs']).to eq(
            'app/services/bar_stuff/**' => CodeFeatures.find('Bar'),
            'frontend/javascripts/bar_stuff/**' => CodeFeatures.find('Bar')
          )
          expect(glob_cache.raw_cache_contents['Feature Assigned in .feature'].length).to eq(1)
          expect(glob_cache.raw_cache_contents['Feature Assigned in .feature']).to eq('directory/my_feature/**/**' => CodeFeatures.find('Bar'))
          expect(glob_cache.raw_cache_contents['Feature YML assignment']).to eq('config/features/bar.yml' => CodeFeatures.find('Bar'))
        end
      end

      context 'when the FEATURES.yml file contains multiple features' do
        before do
          write_configuration

          write_file('config/features/bar.yml', <<~CONTENTS)
            name: Bar
          CONTENTS

          write_file('config/features/foo.yml', <<~CONTENTS)
            name: Foo
          CONTENTS

          write_file('FEATURES.yml', <<~CONTENTS)
            # STOP! - DO NOT EDIT THIS FILE MANUALLY
            # This file was automatically generated by "bin/featuremap validate". The next time this file
            # is generated any changes will be lost. For more details:
            # https://github.com/Beyond-Finance/feature_map

            ---
            files:
              app/my_error.rb:
                feature: Bar
                mapper: Annotations at the top of file
              app/my_file.rb:
                feature: Foo
                mapper: Annotations at the top of file
              config/features/bar.yml:
                feature: Bar
                mapper: Feature YML assignment
              config/features/foo.yml:
                feature: Foo
                mapper: Feature YML assignment
            features:
              Bar:
                files:
                - app/my_error.rb
                - config/features/bar.yml
              Foo:
                files:
                - app/my_file.rb
                - config/features/foo.yml
          CONTENTS
        end

        it 'initializes the glob cache properly from the FEATURES.yml file' do
          glob_cache = Private::FeaturesFile.to_glob_cache
          expect(glob_cache).to be_a(Private::GlobCache)
          expect(glob_cache.raw_cache_contents.keys).to eq(['Annotations at the top of file', 'Feature YML assignment'])
          expect(glob_cache.raw_cache_contents['Annotations at the top of file'].length).to eq(2)
          expect(glob_cache.raw_cache_contents['Annotations at the top of file']).to eq(
            'app/my_error.rb' => CodeFeatures.find('Bar'),
            'app/my_file.rb' => CodeFeatures.find('Foo')
          )
          expect(glob_cache.raw_cache_contents['Feature YML assignment'].length).to eq(2)
          expect(glob_cache.raw_cache_contents['Feature YML assignment']).to eq(
            'config/features/bar.yml' => CodeFeatures.find('Bar'),
            'config/features/foo.yml' => CodeFeatures.find('Foo')
          )
        end
      end
    end
  end
end
