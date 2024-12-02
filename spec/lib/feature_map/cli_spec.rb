RSpec.describe FeatureMap::Cli do
  subject { FeatureMap::Cli.run!(argv) }

  describe 'validate' do
    let(:argv) { ['validate'] }
    let(:assigned_globs) { nil }

    before do
      write_configuration(assigned_globs: assigned_globs)
      write_file('app/services/my_file.rb')
      write_file('frontend/javascripts/my_file.jsx')
    end

    context 'when run without arguments' do
      it 'runs validations with the right defaults' do
        expect(FeatureMap).to receive(:validate!) do |args|
          expect(args[:autocorrect]).to eq true
          expect(args[:stage_changes]).to eq true
          expect(args[:files]).to be_nil
        end
        subject
      end
    end

    context 'with --diff argument' do
      let(:argv) { ['validate', '--diff'] }

      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('FEATUREMAP_GIT_STAGED_FILES').and_return('app/services/my_file.rb')
      end

      context 'when there are multiple assigned_globs' do
        let(:assigned_globs) { ['app/*/**', 'lib/*/**'] }

        it 'validates the tracked file' do
          expect { subject }.to raise_error FeatureMap::InvalidFeatureMapConfigurationError
        end
      end
    end
  end

  describe 'docs' do
    let(:argv) { ['docs'] }
    let(:assigned_globs) { nil }

    before do
      create_non_empty_application
      create_validation_artifacts
    end

    context 'when run without arguments' do
      it 'runs validations with the right defaults' do
        expect(FeatureMap).to receive(:validate!) do |args|
          expect(args[:stage_changes]).to eq true
        end
        expect(FeatureMap).to receive(:generate_docs!)
        subject
      end
    end

    context 'with --skip-validate' do
      let(:argv) { ['docs', '--skip-validate'] }

      it 'does not trigger the validate operation' do
        expect(FeatureMap).not_to receive(:validate!)
        expect(FeatureMap).to receive(:generate_docs!)
        subject
      end
    end
  end

  describe 'for_file' do
    before do
      write_configuration

      write_file('app/services/my_file.rb')
      write_file('.feature_map/definitions/onboarding.yml', <<~YML)
        name: Onboarding
        assigned_globs:#{' '}
          - 'app/**/*.rb'
      YML
    end

    context 'when run with no flags' do
      context 'when run with one file' do
        let(:argv) { ['for_file', 'app/services/my_file.rb'] }

        it 'outputs the feature info in human readable format' do
          expect(FeatureMap::Cli).to receive(:puts).with(<<~MSG)
            Feature: Onboarding
            Feature YML: .feature_map/definitions/onboarding.yml
          MSG
          subject
        end
      end

      context 'when run with no files' do
        let(:argv) { ['for_file'] }

        it 'raises an error indicating that a single file is required' do
          expect { subject }.to raise_error 'Please pass in one file. Use `bin/featuremap for_file --help` for more info'
        end
      end

      context 'when run with multiple files' do
        let(:argv) { ['for_file', 'app/services/my_file.rb', 'app/services/my_file2.rb'] }

        it 'raises an error indicating that a single file is required' do
          expect { subject }.to raise_error 'Please pass in one file. Use `bin/featuremap for_file --help` for more info'
        end
      end
    end

    context 'when run with --json' do
      let(:argv) { ['for_file', '--json', 'app/services/my_file.rb'] }

      context 'when run with one file' do
        it 'outputs JSONified information to the console' do
          json = {
            feature_name: 'Onboarding',
            feature_yml: '.feature_map/definitions/onboarding.yml'
          }
          expect(FeatureMap::Cli).to receive(:puts).with(json.to_json)
          subject
        end
      end

      context 'when run with no files' do
        let(:argv) { ['for_file', '--json'] }

        it 'raises an error indicating that a single file is required' do
          expect { subject }.to raise_error 'Please pass in one file. Use `bin/featuremap for_file --help` for more info'
        end
      end

      context 'when run with multiple files' do
        let(:argv) { ['for_file', 'app/services/my_file.rb', 'app/services/my_file2.rb'] }

        it 'raises an error indicating that a single file is required' do
          expect { subject }.to raise_error 'Please pass in one file. Use `bin/featuremap for_file --help` for more info'
        end
      end
    end
  end

  describe 'using unknown command' do
    let(:argv) { ['some_command'] }

    it 'outputs help text' do
      expect(FeatureMap::Cli).to receive(:puts).with("'some_command' is not a feature_map command. See `bin/featuremap help`.")
      subject
    end
  end

  describe 'passing in no command' do
    let(:argv) { [] }

    it 'outputs help text' do
      expected = <<~EXPECTED
        Usage: bin/featuremap <subcommand>

        Subcommands:
          validate - run all validations
          docs - generates feature documentation
          for_file - find feature assignment for a single file
          for_feature - find assignment information for a feature
          help  - display help information about feature_map
      EXPECTED
      expect(FeatureMap::Cli).to receive(:puts).with(expected)
      subject
    end
  end
end
