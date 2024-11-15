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

          write_file('.features/definitions/bar.yml', <<~CONTENTS)
            name: Bar
          CONTENTS
        end

        context 'the file is not in unassigned_globs' do
          before do
            write_configuration
          end

          context 'when no require_assignment_for_teams configuration is set' do
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

          context 'when a set of teams is specified in the require_assignment_for_teams configuration' do
            before do
              write_file('config/code_ownership.yml', <<~CONTENTS)
                owned_globs: ['app/**/**']
              CONTENTS

              # The CodeOwnership gem and its underlying dependencies do a lot of internal caching. The following
              # operations are required to reset these caches between each test to avoid polluting state across tests.
              CodeOwnership.bust_caches!
              CodeTeams.bust_caches!

              write_configuration('unassigned_globs' => ['config/teams/**'], 'require_assignment_for_teams' => ['Assigned Team'])
            end

            context 'when the file is assigned to a team that IS in the require_assignment_for_teams set' do
              before do
                write_file('config/teams/assigned_team.yml', <<~CONTENTS)
                  name: Assigned Team
                  github:
                    team: '@My-Org/assigned-team'
                  owned_globs: ['app/missing_assignment.rb']
                CONTENTS
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

            context 'when the file is not assigned to any team' do
              it 'does not raise an error' do
                expect { FeatureMap.validate! }.to_not raise_error
              end
            end

            context 'when the file is assigned to a team that IS NOT in the require_assignment_for_teams set' do
              before do
                write_file('config/teams/unassigned_team.yml', <<~CONTENTS)
                  name: UnAssigned Team
                  github:
                    team: '@My-Org/unassigned-team'
                  owned_globs: ['app/missing_assignment.rb']
                CONTENTS
              end

              it 'does not raise an error' do
                expect { FeatureMap.validate! }.to_not raise_error
              end
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
