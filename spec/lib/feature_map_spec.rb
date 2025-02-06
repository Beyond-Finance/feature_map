RSpec.describe FeatureMap do
  # Look at individual validations spec to see other validaions that ship with FeatureMap
  describe '.validate!' do
    describe 'features must exist validation' do
      before do
        write_file('.feature_map/definitions/bar.yml', <<~CONTENTS)
          name: Bar
        CONTENTS

        write_configuration
      end

      context 'directory with [] characters' do
        before do
          write_file('app/services/.feature', <<~CONTENTS)
            Bar
          CONTENTS
          write_file('app/services/test/some_unassigned_file.rb', '')
          write_file('app/services/[test]/some_unassigned_file.rb', '')
        end

        it 'has no validation errors' do
          expect { FeatureMap.validate!(files: ['app/services/test/some_unassigned_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate!(files: ['app/services/[test]/some_unassigned_file.rb']) }.to_not raise_error
        end
      end

      context 'directory with [] characters containing a .feature file' do
        before do
          write_file('app/services/[test]/.feature', <<~CONTENTS)
            Bar
          CONTENTS
          write_file('app/services/[test]/some_file.rb', '')
        end

        it 'has no validation errors' do
          expect { FeatureMap.validate!(files: ['app/services/[test]/some_file.rb']) }.to_not raise_error
        end
      end

      context 'file assignment with [] characters' do
        before do
          write_file('app/services/[test]/some_file.ts', <<~TYPESCRIPT)
            // @feature Bar
            // Countries
          TYPESCRIPT
        end

        it 'has no validation errors' do
          expect { FeatureMap.validate!(files: ['app/services/withoutbracket/some_other_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate!(files: ['app/services/[test]/some_other_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate!(files: ['app/services/*/some_other_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate!(files: ['app/*/[test]/some_other_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate! }.to_not raise_error
        end
      end

      context 'invalid feature in a file annotation' do
        before do
          write_file('app/some_file.rb', <<~CONTENTS)
            # @feature Foo
          CONTENTS
        end

        it 'lets the user know the feature cannot be found in the file' do
          expect { FeatureMap.validate! }.to raise_error do |e|
            expect(e).to be_a StandardError
            expect(e.message).to eq <<~EXPECTED.chomp
              Could not find feature with name: `Foo` in app/some_file.rb. Make sure the feature is one of `["Bar"]`
            EXPECTED
          end
        end
      end
    end

    context 'file is unassigned' do
      before do
        write_file('.feature_map/definitions/bar.yml', <<~CONTENTS)
          name: Bar
        CONTENTS

        write_configuration

        write_file('app/services/autogenerated_code/some_unassigned_file.rb', '')
      end

      it 'has no validation errors' do
        expect { FeatureMap.validate!(files: ['app/services/autogenerated_code/some_unassigned_file.rb']) }.to raise_error do |e|
          expect(e.message).to eq <<~MSG.chomp
            Some files are missing a feature assignment:

            - app/services/autogenerated_code/some_unassigned_file.rb

            See https://github.com/Beyond-Finance/feature_map#README.md for more details
          MSG
        end
      end

      context 'ignored file passed in that is ignored' do
        before do
          write_configuration('unassigned_globs' => ['app/services/autogenerated_code/**/**', 'vendor/bundle/**/**'])
        end

        it 'has no validation errors' do
          expect { FeatureMap.validate!(files: ['app/services/autogenerated_code/some_unassigned_file.rb']) }.to_not raise_error
        end
      end
    end
  end

  # See tests for individual assignment_mappers to understand behavior for each mapper
  describe '.for_file' do
    describe 'path formatting expectations' do
      # All file paths must be clean paths relative to the root: https://apidock.com/ruby/Pathname/cleanpath
      it 'will not find the assignment of a file that is not a cleanpath' do
        expect(FeatureMap.for_file('packs/my_pack/assigned_file.rb')).to eq FeatureMap::CodeFeatures.find('Bar')
        expect(FeatureMap.for_file('./packs/my_pack/assigned_file.rb')).to eq nil
      end
    end

    context '.feature in a directory with [] characters' do
      before do
        write_file('app/javascript/[test]/.feature', <<~CONTENTS)
          Bar
        CONTENTS
        write_file('app/javascript/[test]/test.js', '')
      end

      it 'properly assigns feature' do
        expect(FeatureMap.for_file('app/javascript/[test]/test.js')).to eq FeatureMap::CodeFeatures.find('Bar')
      end
    end

    before { create_non_empty_application }
  end

  describe '.for_backtrace' do
    before { create_files_with_defined_classes }

    context 'excluded_features is not passed in as an input parameter' do
      it 'finds the right feature' do
        expect { MyFile.raise_error }.to raise_error do |ex|
          expect(FeatureMap.for_backtrace(ex.backtrace)).to eq FeatureMap::CodeFeatures.find('Bar')
        end
      end
    end

    context 'excluded_features is passed in as an input parameter' do
      it 'ignores the first part of the stack trace and finds the next viable feature' do
        expect { MyFile.raise_error }.to raise_error do |ex|
          feature_to_exclude = FeatureMap::CodeFeatures.find('Bar')
          expect(FeatureMap.for_backtrace(ex.backtrace, excluded_features: [feature_to_exclude])).to eq FeatureMap::CodeFeatures.find('Foo')
        end
      end
    end
  end

  describe '.first_assigned_file_for_backtrace' do
    before { create_files_with_defined_classes }

    context 'excluded_features is not passed in as an input parameter' do
      it 'finds the right feature' do
        expect { MyFile.raise_error }.to raise_error do |ex|
          expect(FeatureMap.first_assigned_file_for_backtrace(ex.backtrace)).to eq [FeatureMap::CodeFeatures.find('Bar'), 'app/my_error.rb']
        end
      end
    end

    context 'excluded_features is not passed in as an input parameter' do
      it 'finds the right feature' do
        expect { MyFile.raise_error }.to raise_error do |ex|
          feature_to_exclude = FeatureMap::CodeFeatures.find('Bar')
          expect(FeatureMap.first_assigned_file_for_backtrace(ex.backtrace, excluded_features: [feature_to_exclude])).to eq [FeatureMap::CodeFeatures.find('Foo'), 'app/my_file.rb']
        end
      end
    end

    context 'when nothing is assigned a feature' do
      it 'returns nil' do
        expect { raise 'opsy' }.to raise_error do |ex|
          expect(FeatureMap.first_assigned_file_for_backtrace(ex.backtrace)).to be_nil
        end
      end
    end
  end

  describe '.for_class' do
    before { create_files_with_defined_classes }

    it 'can find the right feature for a class' do
      expect(FeatureMap.for_class(MyFile)).to eq FeatureMap::CodeFeatures.find('Foo')
    end

    it 'memoizes the values' do
      expect(FeatureMap.for_class(MyFile)).to eq FeatureMap::CodeFeatures.find('Foo')
      allow(FeatureMap).to receive(:for_file)
      allow(Object).to receive(:const_source_location)
      expect(FeatureMap.for_class(MyFile)).to eq FeatureMap::CodeFeatures.find('Foo')

      # Memoization should avoid these calls
      expect(FeatureMap).to_not have_received(:for_file)
      expect(Object).to_not have_received(:const_source_location)
    end

    it 'returns nil if the class constant cannot be found' do
      allow(FeatureMap).to receive(:for_file)
      allow(Object).to receive(:const_source_location).and_raise(NameError)
      expect(FeatureMap.for_class(MyFile)).to eq nil
    end
  end

  describe '.for_feature' do
    before { create_non_empty_application }

    it 'prints out feature report for the given feature' do
      expect(FeatureMap.for_feature('Bar')).to eq <<~FEATURE_REPORT
        # Report for `Bar` Feature
        ## Annotations at the top of file
        - frontend/javascripts/packages/my_package/assigned_file.jsx
        - packs/my_pack/assigned_file.rb

        ## Feature-specific assigned globs
        - app/services/bar_stuff/**
        - frontend/javascripts/bar_stuff/**

        ## Feature Assigned in .feature
        - directory/my_feature/**/**

        ## Feature definition file assignment
        - .feature_map/definitions/bar.yml
      FEATURE_REPORT
    end
  end

  describe '.generate_docs!' do
    context 'when validation artifacts are present' do
      before { create_validation_artifacts }

      it 'generates a static documentation site within the .feature_map directory' do
        FeatureMap.generate_docs!('some_feature_branch_or_git_sha')
        expect(File.exist?(Pathname.pwd.join('.feature_map/docs/index.html'))).to be_truthy
      end

      it 'defaults git ref when not passed' do
        write_configuration('repository' => { 'main_branch' => 'main' })
        FeatureMap.generate_docs!(nil)

        expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to match('"git_ref":"main"')
      end

      context 'when test coverage artifacts are present' do
        before { create_test_coverage_artifacts }

        it 'captures the feature details for the current application within a feature-map-config.js file that includes feature metrics and test coverage data' do
          FeatureMap.generate_docs!('some_feature_branch_or_git_sha')

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to match('window.FEATURE_MAP_CONFIG')
        end
      end

      context 'when test coverage artifacts are NOT present' do
        it 'captures the feature details for the current application within a feature-map-config.js file that includes ONLY feature metrics data' do
          FeatureMap.generate_docs!('some_feature_branch_or_git_sha')

          expect(File.exist?(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to be_truthy
          expect(File.read(Pathname.pwd.join('.feature_map/docs/feature-map-config.js'))).to match('window.FEATURE_MAP_CONFIG')
        end
      end
    end

    context 'when validation artifacts are NOT present' do
      it 'raises an error indicating that this data is required' do
        expect { FeatureMap.generate_docs!('some_feature_branch_or_git_sha') }.to raise_error(/No feature assignments file found/i)
      end
    end
  end

  describe '.generate_test_pyramid' do
    before do
      create_test_coverage_artifacts

      write_file('tmp/unit.rspec', <<~CONTENTS)
        { "examples": []}
      CONTENTS
      write_file('tmp/integration.rspec', <<~CONTENTS)
        { "examples": []}
      CONTENTS
      write_file('tmp/regression.rspec', <<~CONTENTS)
        { "examples": []}
      CONTENTS
      write_file('regression/.feature_map/assignments.yml', <<~CONTENTS)
        ---
        files: {}
        features: {}
      CONTENTS
    end

    it 'generates the test pyramid file' do
      FeatureMap.generate_test_pyramid!(
        'tmp/unit.rspec',
        'tmp/integration.rspec',
        'tmp/regression.rspec',
        'regression/.feature_map/assignments.yml'
      )

      expect(File.exist?(Pathname.pwd.join('.feature_map/test-pyramid.yml'))).to be_truthy
    end
  end

  describe '.apply_assignments!' do
    before do
      create_test_coverage_artifacts

      write_file('tmp/assignments.csv', <<~CONTENTS)
        app/foo.rb,Foo
      CONTENTS
      write_file('app/foo.rb', <<~CONTENTS)
        class Foo
        end
      CONTENTS
    end

    it 'applies assignments' do
      FeatureMap.apply_assignments!(
        'tmp/assignments.csv'
      )

      expect(File.read('app/foo.rb')).to eq(<<~CONTENTS)
        # @feature Foo
        class Foo
        end
      CONTENTS
    end
  end

  describe '.gather_test_coverage!' do
    let(:commit_sha) { '1234567890abcdef1234567890abcdef' }
    let(:code_cov_token) { 'e5124eb5-c948-4136-9297-08efa6f2d537' }
    let(:code_cov_service) { 'github' }
    let(:code_cov_owner) { 'Acme-Org' }
    let(:code_cov_repo) { 'sample_app' }
    let(:test_coverage_output_file) { Pathname.pwd.join('.feature_map/test-coverage.yml') }
    let(:code_cov_response) do
      {
        report: {
          files: [{ name: 'app/my_error.rb', totals: { lines: 10, hits: 8, misses: 2 } }]
        }
      }
    end

    before do
      create_validation_artifacts
      write_configuration('code_cov' => { 'service' => code_cov_service, 'owner' => code_cov_owner, 'repo' => code_cov_repo })
      stub_request(:get, "https://api.codecov.io/api/v2/#{code_cov_service}/#{code_cov_owner}/repos/#{code_cov_repo}/commits/#{commit_sha}")
        .with(headers: { 'Authorization' => "Bearer #{code_cov_token}" })
        .to_return(status: 200, body: code_cov_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'captures the test coverage statistics for all features in a test-coverage.yml file within the .feature_map directory' do
      FeatureMap.gather_test_coverage!(commit_sha, code_cov_token)
      expect(File.exist?(test_coverage_output_file)).to be_truthy
      expect(YAML.load_file(test_coverage_output_file)).to match({
                                                                   'features' => {
                                                                     'Bar' => { 'hits' => 8, 'lines' => 10, 'misses' => 2 },
                                                                     'Foo' => { 'hits' => 0, 'lines' => 0, 'misses' => 0 }
                                                                   }
                                                                 })
    end
  end

  describe '.group_commits' do
    let(:foo_and_bar_commit) { FeatureMap::Commit.new(sha: 'aaa111', description: 'A test change impacting both Foo and Bar.', pull_request_number: '111', files: ['app/my_file.rb', 'app/my_error.rb']) }
    let(:foo_commit) { FeatureMap::Commit.new(sha: 'bbb222', description: 'A Foo only change.', pull_request_number: '222', files: ['app/my_file.rb']) }
    let(:bar_commit) { FeatureMap::Commit.new(sha: 'ccc333', description: 'A Bar only change.', pull_request_number: '333', files: ['app/my_error.rb']) }

    before { create_validation_artifacts }

    context 'when CodeOwnership is not being used' do
      it 'groups all features under a single key representing all teams' do
        grouped_commits = FeatureMap.group_commits([foo_commit, foo_and_bar_commit, bar_commit])
        expect(grouped_commits).to eq({
                                        'All Teams' => {
                                          'Foo' => %w[bbb222 aaa111],
                                          'Bar' => %w[aaa111 ccc333]
                                        }
                                      })
      end
    end

    context 'when CodeOwnership is being used' do
      before do
        create_files_with_team_assignments

        write_file('.feature_map/assignments.yml', <<~CONTENTS)
          ---
          files:
          features:
            Bar:
              files:
              - app/my_error.rb
              - app/other_team_b_stuff.rb
            Foo:
              files:
              - app/my_file.rb
              - app/foo_stuff_owned_by_team_a.rb
              - app/foo_stuff_owned_by_team_b.rb
        CONTENTS
      end

      it 'groups all features under the teams responsible for them' do
        grouped_commits = FeatureMap.group_commits([foo_commit, foo_and_bar_commit, bar_commit])
        expect(grouped_commits).to eq({
                                        'Team A' => {
                                          'Foo' => %w[bbb222 aaa111]
                                        },
                                        'Team B' => {
                                          'Foo' => %w[bbb222 aaa111],
                                          'Bar' => %w[aaa111 ccc333]
                                        }
                                      })
      end

      it 'lists features that have no responsible team unde a key representing all teams' do
        write_file('app/shared.rb', 'class Shared; end')
        write_file('.feature_map/definitions/shared.yml', <<~CONTENTS)
          name: Shared
          assigned_globs:
            - app/shared.rb
        CONTENTS
        shared_commit = FeatureMap::Commit.new(sha: 'fff555', description: 'Change to a feature with no assigned team.', files: ['app/shared.rb'])

        grouped_commits = FeatureMap.group_commits([shared_commit])
        expect(grouped_commits).to eq({
                                        'All Teams' => {
                                          'Shared' => ['fff555']
                                        }
                                      })
      end

      it 'ignores files with no assigned feature' do
        featureless_commit = FeatureMap::Commit.new(sha: 'fff555', description: 'Change to a file with no feature.', files: ['app/featureless.rb'])
        grouped_commits = FeatureMap.group_commits([featureless_commit])
        expect(grouped_commits).to eq({})
      end

      it 'lists only features modified within the specified commits' do
        grouped_commits = FeatureMap.group_commits([bar_commit])
        expect(grouped_commits).to eq({
                                        'Team B' => {
                                          'Bar' => ['ccc333']
                                        }
                                      })
      end

      it 'lists teams who are responsible for any file of a features modified within the specified commits, even if the teams files were NOT modified in the specified commits' do
        team_a_commit = FeatureMap::Commit.new(sha: 'eee444', description: 'Change made by Team A to a Foo file.', files: ['app/foo_stuff_owned_by_team_a.rb'])
        grouped_commits = FeatureMap.group_commits([team_a_commit])
        expect(grouped_commits).to eq({
                                        'Team A' => {
                                          'Foo' => ['eee444']
                                        },
                                        'Team B' => {
                                          'Foo' => ['eee444']
                                        }
                                      })
      end
    end
  end

  describe '.generate_release_notification' do
    let(:foo_and_bar_commit) { FeatureMap::Commit.new(sha: 'aaa111', description: 'A test change impacting both Foo and Bar.', pull_request_number: '111', files: ['app/my_file.rb', 'app/my_error.rb']) }
    let(:foo_commit) { FeatureMap::Commit.new(sha: 'bbb222', description: 'A Foo only change.', pull_request_number: '222', files: ['app/my_file.rb']) }
    let(:bar_commit) { FeatureMap::Commit.new(sha: 'ccc333', description: 'A Bar only change.', pull_request_number: '333', files: ['app/my_error.rb']) }
    let(:commits_by_feature) { { 'Foo' => [foo_and_bar_commit, foo_commit], 'Bar' => [bar_commit, foo_and_bar_commit] } }

    before { create_files_with_defined_classes }

    it 'generated a release notification payload for the specified set of commits' do
      payload = FeatureMap.generate_release_notification(commits_by_feature)
      expect(payload).to eq([
                              {
                                type: 'section',
                                text: {
                                  type: 'mrkdwn',
                                  text: "*_Bar_*\n• A Bar only change.\n• A test change impacting both Foo and Bar."
                                }
                              },
                              { type: 'divider' },
                              {
                                type: 'section',
                                text: {
                                  type: 'mrkdwn',
                                  text: "*_Foo_*\n• A test change impacting both Foo and Bar.\n• A Foo only change."
                                }
                              }
                            ])
    end
  end
end
