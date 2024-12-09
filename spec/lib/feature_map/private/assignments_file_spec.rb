module FeatureMap
  RSpec.describe Private::AssignmentsFile do
    describe '.actual_contents_lines' do
      it 'returns an array of files from the existing .feature_map/assignments.yml file' do
        write_file('.feature_map/assignments.yml', <<~YML)
          # STOP! - DO NOT EDIT THIS FILE MANUALLY
          # This file was automatically generated by "bin/featuremap validate". The next time this file
          # is generated any changes will be lost. For more details:
          # https://github.com/Beyond-Finance/feature_map
          #
          # It is recommended to commit this file into your source control. It will only change when the
          # set of files assigned to a feature change, which should be explicitly tracked.

          ---
          files:
            app/services/my_assignable_file.rb:
              feature: Bar
              mapper: Annotations at the top of file
            ".feature_map/definitions/bar.yml":
              feature: Bar
              mapper: Feature definition file assignment
            ".feature_map/definitions/foo.yml":
              feature: Foo
              mapper: Feature definition file assignment
            lib/foo_logic.rb:
              feature: Foo
              mapper: Feature Assigned in .feature
          features:
            Bar:
              files:
              - app/services/my_assignable_file.rb
              - ".feature_map/definitions/bar.yml"
            Foo:
              files:
              - ".feature_map/definitions/foo.yml"
              - lib/foo_logic.rb
        YML

        expect(Private::AssignmentsFile.actual_contents_lines).to eq([
                                                                       '# STOP! - DO NOT EDIT THIS FILE MANUALLY',
                                                                       '# This file was automatically generated by "bin/featuremap validate". The next time this file',
                                                                       '# is generated any changes will be lost. For more details:',
                                                                       '# https://github.com/Beyond-Finance/feature_map',
                                                                       '#',
                                                                       '# It is recommended to commit this file into your source control. It will only change when the',
                                                                       '# set of files assigned to a feature change, which should be explicitly tracked.',
                                                                       '',
                                                                       '---',
                                                                       'files:',
                                                                       '  app/services/my_assignable_file.rb:',
                                                                       '    feature: Bar',
                                                                       '    mapper: Annotations at the top of file',
                                                                       '  ".feature_map/definitions/bar.yml":',
                                                                       '    feature: Bar',
                                                                       '    mapper: Feature definition file assignment',
                                                                       '  ".feature_map/definitions/foo.yml":',
                                                                       '    feature: Foo',
                                                                       '    mapper: Feature definition file assignment',
                                                                       '  lib/foo_logic.rb:',
                                                                       '    feature: Foo',
                                                                       '    mapper: Feature Assigned in .feature',
                                                                       'features:',
                                                                       '  Bar:',
                                                                       '    files:',
                                                                       '    - app/services/my_assignable_file.rb',
                                                                       '    - ".feature_map/definitions/bar.yml"',
                                                                       '  Foo:',
                                                                       '    files:',
                                                                       '    - ".feature_map/definitions/foo.yml"',
                                                                       '    - lib/foo_logic.rb',
                                                                       ''
                                                                     ])
      end

      context 'when NO assignments.yml file exists' do
        it 'returns an array with a single empty string' do
          expect(Private::AssignmentsFile.actual_contents_lines).to eq([''])
        end
      end
    end

    describe '.expected_contents_lines' do
      context 'when files are assigned using multiple mappers' do
        before { create_non_empty_application }

        it 'generates the expected content' do
          result = Private::AssignmentsFile.expected_contents_lines
          expected = [
            '# STOP! - DO NOT EDIT THIS FILE MANUALLY',
            '# This file was automatically generated by "bin/featuremap validate". The next time this file',
            '# is generated any changes will be lost. For more details:',
            '# https://github.com/Beyond-Finance/feature_map',
            '#',
            '# It is recommended to commit this file into your source control. It will only change when the',
            '# set of files assigned to a feature change, which should be explicitly tracked.',
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
            '  ".feature_map/definitions/bar.yml":',
            '    feature: Bar',
            '    mapper: Feature definition file assignment',
            'features:',
            '  Bar:',
            '    files:',
            '    - ".feature_map/definitions/bar.yml"',
            '    - app/services/bar_stuff/thing.rb',
            '    - directory/my_feature/some_directory_file.ts',
            '    - frontend/javascripts/bar_stuff/thing.jsx',
            '    - frontend/javascripts/packages/my_package/assigned_file.jsx',
            '    - packs/my_pack/assigned_file.rb',
            ''
          ]

          expect(result).to eq(expected)
        end
      end

      context 'when multiple features are assigned to files' do
        before { create_files_with_defined_classes }

        it 'generates the expected content' do
          expect(Private::AssignmentsFile.expected_contents_lines).to eq([
                                                                           '# STOP! - DO NOT EDIT THIS FILE MANUALLY',
                                                                           '# This file was automatically generated by "bin/featuremap validate". The next time this file',
                                                                           '# is generated any changes will be lost. For more details:',
                                                                           '# https://github.com/Beyond-Finance/feature_map',
                                                                           '#',
                                                                           '# It is recommended to commit this file into your source control. It will only change when the',
                                                                           '# set of files assigned to a feature change, which should be explicitly tracked.',
                                                                           '',
                                                                           '---',
                                                                           'files:',
                                                                           '  app/my_error.rb:',
                                                                           '    feature: Bar',
                                                                           '    mapper: Annotations at the top of file',
                                                                           '  app/my_file.rb:',
                                                                           '    feature: Foo',
                                                                           '    mapper: Annotations at the top of file',
                                                                           '  ".feature_map/definitions/bar.yml":',
                                                                           '    feature: Bar',
                                                                           '    mapper: Feature definition file assignment',
                                                                           '  ".feature_map/definitions/foo.yml":',
                                                                           '    feature: Foo',
                                                                           '    mapper: Feature definition file assignment',
                                                                           'features:',
                                                                           '  Bar:',
                                                                           '    files:',
                                                                           '    - ".feature_map/definitions/bar.yml"',
                                                                           '    - app/my_error.rb',
                                                                           '  Foo:',
                                                                           '    files:',
                                                                           '    - ".feature_map/definitions/foo.yml"',
                                                                           '    - app/my_file.rb',
                                                                           ''
                                                                         ])
        end
      end

      context 'when features are encountered in different orders while walking the file tree' do
        before do
          create_files_with_defined_classes
          # When the feature definition files are included they are always encountered first in alphabetical order.
          # Excluding them allows the order in which features are encountered in the file tree to be controlled and
          # tested.
          write_configuration('ignore_feature_definitions' => true)
        end

        context 'when the Bar feature is encountered first' do
          before { write_file('app/abc.rb', "# @feature Bar\n") }
          let(:expected_lines) do
            [
              '# STOP! - DO NOT EDIT THIS FILE MANUALLY',
              '# This file was automatically generated by "bin/featuremap validate". The next time this file',
              '# is generated any changes will be lost. For more details:',
              '# https://github.com/Beyond-Finance/feature_map',
              '#',
              '# It is recommended to commit this file into your source control. It will only change when the',
              '# set of files assigned to a feature change, which should be explicitly tracked.',
              '',
              '---',
              'files:',
              '  app/abc.rb:',
              '    feature: Bar',
              '    mapper: Annotations at the top of file',
              '  app/my_error.rb:',
              '    feature: Bar',
              '    mapper: Annotations at the top of file',
              '  app/my_file.rb:',
              '    feature: Foo',
              '    mapper: Annotations at the top of file',
              'features:',
              '  Bar:',
              '    files:',
              '    - app/abc.rb',
              '    - app/my_error.rb',
              '  Foo:',
              '    files:',
              '    - app/my_file.rb',
              ''
            ]
          end

          it 'uses alphabetical order in the features section' do
            expect(Private::AssignmentsFile.expected_contents_lines).to eq(expected_lines)
          end
        end

        context 'when the Foo feature is encountered first' do
          before { write_file('app/abc.rb', "# @feature Foo\n") }
          let(:expected_lines) do
            [
              '# STOP! - DO NOT EDIT THIS FILE MANUALLY',
              '# This file was automatically generated by "bin/featuremap validate". The next time this file',
              '# is generated any changes will be lost. For more details:',
              '# https://github.com/Beyond-Finance/feature_map',
              '#',
              '# It is recommended to commit this file into your source control. It will only change when the',
              '# set of files assigned to a feature change, which should be explicitly tracked.',
              '',
              '---',
              'files:',
              '  app/abc.rb:',
              '    feature: Foo',
              '    mapper: Annotations at the top of file',
              '  app/my_error.rb:',
              '    feature: Bar',
              '    mapper: Annotations at the top of file',
              '  app/my_file.rb:',
              '    feature: Foo',
              '    mapper: Annotations at the top of file',
              'features:',
              '  Bar:',
              '    files:',
              '    - app/my_error.rb',
              '  Foo:',
              '    files:',
              '    - app/abc.rb',
              '    - app/my_file.rb',
              ''
            ]
          end

          it 'uses alphabetical order in the features section' do
            expect(Private::AssignmentsFile.expected_contents_lines).to eq(expected_lines)
          end
        end
      end

      context 'when CodeOwnership team assignments are enabled' do
        before do
          create_files_with_defined_classes
          create_files_with_team_assignments
          write_configuration('unassigned_globs' => ['.feature_map/config.yml', 'config/code_ownership.yml'], 'skip_code_ownership' => false)
        end

        let(:expected_lines) do
          [
            '# STOP! - DO NOT EDIT THIS FILE MANUALLY',
            '# This file was automatically generated by "bin/featuremap validate". The next time this file',
            '# is generated any changes will be lost. For more details:',
            '# https://github.com/Beyond-Finance/feature_map',
            '#',
            '# It is recommended to commit this file into your source control. It will only change when the',
            '# set of files assigned to a feature change, which should be explicitly tracked.',
            '',
            '---',
            'files:',
            '  app/foo_stuff_owned_by_team_a.rb:',
            '    feature: Foo',
            '    mapper: Annotations at the top of file',
            '  app/foo_stuff_owned_by_team_b.rb:',
            '    feature: Foo',
            '    mapper: Annotations at the top of file',
            '  app/my_error.rb:',
            '    feature: Bar',
            '    mapper: Annotations at the top of file',
            '  app/my_file.rb:',
            '    feature: Foo',
            '    mapper: Annotations at the top of file',
            '  app/other_team_b_stuff.rb:',
            '    feature: Bar',
            '    mapper: Annotations at the top of file',
            '  ".feature_map/definitions/bar.yml":',
            '    feature: Bar',
            '    mapper: Feature definition file assignment',
            '  ".feature_map/definitions/foo.yml":',
            '    feature: Foo',
            '    mapper: Feature definition file assignment',
            'features:',
            '  Bar:',
            '    files:',
            '    - ".feature_map/definitions/bar.yml"',
            '    - app/my_error.rb',
            '    - app/other_team_b_stuff.rb',
            '    teams:',
            '    - Team B',
            '  Foo:',
            '    files:',
            '    - ".feature_map/definitions/foo.yml"',
            '    - app/foo_stuff_owned_by_team_a.rb',
            '    - app/foo_stuff_owned_by_team_b.rb',
            '    - app/my_file.rb',
            '    teams:',
            '    - Team A',
            '    - Team B',
            ''
          ]
        end

        it 'includes team assignments in the output content' do
          expect(Private::AssignmentsFile.expected_contents_lines).to eq(expected_lines)
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
          #
          # It is recommended to commit this file into your source control. It will only change when the
          # set of files assigned to a feature change, which should be explicitly tracked.

          ---
          files:
            ".feature_map/definitions/foo.yml":
              feature: Foo
              mapper: Feature definition file assignment
          features:
            Foo:
              files:
              - ".feature_map/definitions/foo.yml"
        FEATURES
      end

      before do
        # Must use the skip_features_validation to avoid having the GlobCache loaded from the stub assignments.yml file.
        write_configuration('skip_features_validation' => true)
        write_file('.feature_map/definitions/foo.yml', <<~CONTENTS)
          name: Foo
        CONTENTS
      end

      context 'when NO assignments.yml file exists' do
        it 'overwrites the assignments.yml file with a new set of feature assignment' do
          expect(File.exist?(Private::AssignmentsFile.path)).to be_falsey
          Private::AssignmentsFile.write!
          expect(File.read(Private::AssignmentsFile.path)).to eq(expected_file)
        end
      end

      context 'an existing assignments.yml file exists' do
        before do
          write_file('.feature_map/assignments.yml', <<~CONTENTS)
            # Placeholder to be removed by test.
            ---
            foo: 123
          CONTENTS
        end

        it 'overwrites the assignments.yml file with a new set of feature assignment' do
          expect(File.read(Private::AssignmentsFile.path)).not_to eq(expected_file)
          Private::AssignmentsFile.write!
          expect(File.read(Private::AssignmentsFile.path)).to eq(expected_file)
        end
      end
    end

    describe '.path' do
      it 'returns the path to the assignments.yml file' do
        # Expects path to be something like: /private/var/folders/6d/.../.feature_map/assignments.yml
        expect(Private::AssignmentsFile.path.to_s).to match(%r{/[a-zA-Z0-9-/]+/.feature_map/assignments\.yml})
      end
    end

    describe '.use_features_cache?' do
      let(:skip_features_validation) { false }

      before do
        write_configuration('skip_features_validation' => skip_features_validation)
        write_file('.feature_map/assignments.yml', <<~CONTENTS)
          ---
          files: {}
          features: {}
        CONTENTS
      end

      it 'returns true when the features cache should be used' do
        expect(Private::AssignmentsFile.use_features_cache?).to eq(true)
      end

      context 'when NO assignments.yml file exists' do
        before { assignments_file_path.delete }

        it 'returns false' do
          expect(Private::AssignmentsFile.use_features_cache?).to eq(false)
        end
      end

      context 'when the skip_features_validation configuration setting is set' do
        let(:skip_features_validation) { true }

        it 'returns false' do
          expect(Private::AssignmentsFile.use_features_cache?).to eq(false)
        end
      end
    end

    describe '.to_glob_cache' do
      context 'when the assignments.yml file contains no feature mappings' do
        before do
          write_configuration
          write_file('.feature_map/assignments.yml', <<~CONTENTS)
            ---
            files: {}
            features: {}
          CONTENTS
        end

        it 'initializes an empty GlobCache' do
          glob_cache = Private::AssignmentsFile.to_glob_cache
          expect(glob_cache).to be_a(Private::GlobCache)
          expect(glob_cache.raw_cache_contents).to eq({})
        end
      end

      context 'when the assignments.yml file contains features assigned using multiple mappers' do
        before do
          write_configuration

          write_file('.feature_map/definitions/bar.yml', <<~CONTENTS)
            name: Bar
          CONTENTS

          write_file('.feature_map/assignments.yml', <<~CONTENTS)
            # STOP! - DO NOT EDIT THIS FILE MANUALLY
            # This file was automatically generated by "bin/featuremap validate". The next time this file
            # is generated any changes will be lost. For more details:
            # https://github.com/Beyond-Finance/feature_map
            #
            # It is recommended to commit this file into your source control. It will only change when the
            # set of files assigned to a feature change, which should be explicitly tracked.

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
              ".feature_map/definitions/bar.yml":
                feature: Bar
                mapper: Feature definition file assignment
            features:
              Bar:
              files:
                - app/services/bar_stuff/**'
                - ".feature_map/definitions/bar.yml"
                - directory/my_feature/**/**'
                - frontend/javascripts/bar_stuff/**'
                - frontend/javascripts/packages/my_package/assigned_file.jsx
                - packs/my_pack/assigned_file.rb
          CONTENTS
        end

        it 'initializes the glob cache properly from the assignments.yml file' do
          glob_cache = Private::AssignmentsFile.to_glob_cache
          expect(glob_cache).to be_a(Private::GlobCache)
          expect(glob_cache.raw_cache_contents.keys).to eq(['Annotations at the top of file', 'Feature-specific assigned globs', 'Feature Assigned in .feature', 'Feature definition file assignment'])
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
          expect(glob_cache.raw_cache_contents['Feature definition file assignment']).to eq('.feature_map/definitions/bar.yml' => CodeFeatures.find('Bar'))
        end
      end

      context 'when the assignments.yml file contains multiple features' do
        before do
          write_configuration

          write_file('.feature_map/definitions/bar.yml', <<~CONTENTS)
            name: Bar
          CONTENTS

          write_file('.feature_map/definitions/foo.yml', <<~CONTENTS)
            name: Foo
          CONTENTS

          write_file('.feature_map/assignments.yml', <<~CONTENTS)
            # STOP! - DO NOT EDIT THIS FILE MANUALLY
            # This file was automatically generated by "bin/featuremap validate". The next time this file
            # is generated any changes will be lost. For more details:
            # https://github.com/Beyond-Finance/feature_map
            #
            # It is recommended to commit this file into your source control. It will only change when the
            # set of files assigned to a feature change, which should be explicitly tracked.

            ---
            files:
              app/my_error.rb:
                feature: Bar
                mapper: Annotations at the top of file
              app/my_file.rb:
                feature: Foo
                mapper: Annotations at the top of file
              ".feature_map/definitions/bar.yml":
                feature: Bar
                mapper: Feature definition file assignment
              ".feature_map/definitions/foo.yml":
                feature: Foo
                mapper: Feature definition file assignment
            features:
              Bar:
                files:
                - app/my_error.rb
                - ".feature_map/definitions/bar.yml"
              Foo:
                files:
                - app/my_file.rb
                - ".feature_map/definitions/foo.yml"
          CONTENTS
        end

        it 'initializes the glob cache properly from the assignments.yml file' do
          glob_cache = Private::AssignmentsFile.to_glob_cache
          expect(glob_cache).to be_a(Private::GlobCache)
          expect(glob_cache.raw_cache_contents.keys).to eq(['Annotations at the top of file', 'Feature definition file assignment'])
          expect(glob_cache.raw_cache_contents['Annotations at the top of file'].length).to eq(2)
          expect(glob_cache.raw_cache_contents['Annotations at the top of file']).to eq(
            'app/my_error.rb' => CodeFeatures.find('Bar'),
            'app/my_file.rb' => CodeFeatures.find('Foo')
          )
          expect(glob_cache.raw_cache_contents['Feature definition file assignment'].length).to eq(2)
          expect(glob_cache.raw_cache_contents['Feature definition file assignment']).to eq(
            '.feature_map/definitions/bar.yml' => CodeFeatures.find('Bar'),
            '.feature_map/definitions/foo.yml' => CodeFeatures.find('Foo')
          )
        end
      end
    end

    describe '.load_features!' do
      before { create_validation_artifacts }

      it 'returns the feature metrics details from the existing Metrics File' do
        expect(Private::AssignmentsFile.load_features!).to eq({
                                                                'Bar' => ['app/my_error.rb']
                                                              })
      end

      it 'raises an error if the file does not contain any features content' do
        write_file('.feature_map/assignments.yml', <<~CONTENTS)
          ---
          files:
            app/my_error.rb:
              feature: Bar
              mapper: Annotations at the top of file
        CONTENTS

        expect { Private::AssignmentsFile.load_features! }.to raise_error(Private::AssignmentsFile::FileContentError, /Unexpected content found/i)
      end

      it 'raises an error if the file does not contain an object' do
        write_file('.feature_map/assignments.yml', 'Test 1234')

        expect { Private::AssignmentsFile.load_features! }.to raise_error(Private::AssignmentsFile::FileContentError, /Unexpected content found/i)
      end

      it 'raises an error if the file contains invalid YAML' do
        write_file('.feature_map/assignments.yml', <<~CONTENTS)
          ---
          features:
            Bar:
                - app/my_error.rb
              - some/other/file.rb
        CONTENTS

        expect { Private::AssignmentsFile.load_features! }.to raise_error(Private::AssignmentsFile::FileContentError, /Invalid YAML content/i)
      end

      it 'raises an error if the file is not found' do
        File.delete('.feature_map/assignments.yml')

        expect { Private::AssignmentsFile.load_features! }.to raise_error(Private::AssignmentsFile::FileContentError, /No feature assignments file found/i)
      end
    end
  end
end
