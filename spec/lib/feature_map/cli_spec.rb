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

  describe 'apply_assignments' do
    let(:argv) { ['apply_assignments', 'tmp/assignments.csv'] }

    before do
      create_non_empty_application
      create_validation_artifacts
    end

    it 'uses the provided paths' do
      expect(FeatureMap).to receive(:apply_assignments!).with('tmp/assignments.csv')
      subject
    end

    context 'when missing a file path' do
      let(:argv) { ['apply_assignments'] }

      it 'raises' do
        expect do
          subject
        end.to raise_error('Please specify assignments.csv file')
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
        expect(FeatureMap).to receive(:generate_additional_metrics!)
        expect(FeatureMap).to receive(:generate_docs!)
        subject
      end
    end

    context 'with --skip-validate' do
      let(:argv) { ['docs', '--skip-validate', '--skip-additional-metrics'] }

      it 'does not trigger the validate operation' do
        expect(FeatureMap).not_to receive(:validate!)
        expect(FeatureMap).not_to receive(:generate_additional_metrics!)
        expect(FeatureMap).to receive(:generate_docs!)
        subject
      end
    end
  end

  describe 'test_pyramid' do
    let(:argv) { ['test_pyramid', 'tmp/unit.rspec', 'tmp/integration.rspec', 'tmp/regression.rspec', 'regression/.feature_map/assignments.yml'] }

    before do
      create_non_empty_application
      create_validation_artifacts
    end

    it 'uses the provided paths' do
      expect(FeatureMap).to receive(:generate_test_pyramid!).with('tmp/unit.rspec', 'tmp/integration.rspec', 'tmp/regression.rspec', 'regression/.feature_map/assignments.yml')
      subject
    end

    context 'when only unit and integration test details are provided' do
      let(:argv) { ['test_pyramid', 'tmp/unit.rspec', 'tmp/integration.rspec'] }

      it 'raises' do
        expect(FeatureMap).to receive(:generate_test_pyramid!).with('tmp/unit.rspec', 'tmp/integration.rspec', nil, nil)
        subject
      end
    end

    context 'when missing an incomplete set of arguments are provided' do
      let(:argv) { ['test_pyramid', 'tmp/unit.rspec', 'tmp/integration.rspec', 'tmp/regression.rspec'] }

      it 'raises' do
        expect do
          subject
        end.to raise_error('Please specify at least the [unit_path] and [integration_path] arguments. If regression test details are provided both the [regression_path] and [regression_assignments_path] arguments must be populated.')
      end
    end
  end

  describe 'test_coverage' do
    let(:argv) { ['test_coverage'] }
    let(:assigned_globs) { nil }
    let(:latest_main_commit) { 'fedcba9876543210fedcba9876543210' }
    let(:code_cov_api_token) { 'abc-123-xyz-987' }

    before do
      create_non_empty_application
      create_validation_artifacts
      allow(FeatureMap::Cli).to receive(:`).with('git log -1 --format=%H origin/main').and_return(latest_main_commit)
      stub_const('ENV', ENV.to_h.merge('CODECOV_API_TOKEN' => code_cov_api_token))
    end

    context 'when git sha is provided' do
      let(:commit_sha) { '1234567890abcdef1234567890abcdef' }
      let(:argv) { ['test_coverage', commit_sha] }

      it 'uses the provided commit SHA' do
        expect(FeatureMap).to receive(:gather_test_coverage!).with(commit_sha, code_cov_api_token)
        subject
      end
    end

    context 'when git sha is not provided' do
      it 'defaults to the latest main git sha' do
        expect(FeatureMap).to receive(:gather_test_coverage!).with(latest_main_commit, code_cov_api_token)
        subject
      end
    end

    context 'when no codecov api token can be found' do
      before do
        stub_const('ENV', ENV.to_h.merge('CODECOV_API_TOKEN' => ''))
      end

      it 'raises an exception' do
        expect do
          subject
        end.to raise_error(/Please specify a CodeCov API token in your environment as `CODECOV_API_TOKEN`/)
      end
    end

    context 'when using SimpleCov' do
      let(:simplecov_path) { 'tmp/coverage/.resultset.json' }

      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(simplecov_path).and_return(true)
      end

      context 'with --use-simplecov and --simplecov-path' do
        let(:argv) { ['test_coverage', '--use-simplecov', '--simplecov-path', simplecov_path] }

        it 'uses SimpleCov instead of CodeCov' do
          expect(FeatureMap).to receive(:gather_simplecov_test_coverage!).with([simplecov_path])
          subject
        end
      end

      context 'with multiple --simplecov-path arguments' do
        let(:simplecov_path2) { 'tmp/other_coverage/.resultset.json' }
        let(:argv) { ['test_coverage', '--use-simplecov', '--simplecov-path', simplecov_path, '--simplecov-path', simplecov_path2] }

        before do
          allow(File).to receive(:exist?).with(simplecov_path2).and_return(true)
        end

        it 'passes all paths to the gather_simplecov_test_coverage! method' do
          expect(FeatureMap).to receive(:gather_simplecov_test_coverage!).with([simplecov_path, simplecov_path2])
          subject
        end
      end

      context 'with --use-simplecov but no path specified' do
        let(:argv) { ['test_coverage', '--use-simplecov'] }

        it 'raises an error about missing paths' do
          expect do
            subject
          end.to raise_error('Error: When using --use-simplecov, you must specify at least one path with --simplecov-path.')
        end
      end

      context 'with non-existent path' do
        let(:non_existent_path) { 'non/existent/path.json' }
        let(:argv) { ['test_coverage', '--use-simplecov', '--simplecov-path', non_existent_path] }

        before do
          allow(File).to receive(:exist?).with(non_existent_path).and_return(false)
        end

        it 'raises an error about missing files' do
          expect do
            subject
          end.to raise_error("SimpleCov results file not found: #{non_existent_path}")
        end
      end

      context 'with both SimpleCov options and a commit SHA' do
        let(:commit_sha) { '1234567890abcdef1234567890abcdef' }
        let(:argv) { ['test_coverage', '--use-simplecov', '--simplecov-path', simplecov_path, commit_sha] }

        it 'raises an error about incompatible options' do
          expect do
            subject
          end.to raise_error('Error: Cannot specify a commit SHA when using --simplecov. These options are incompatible.')
        end
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
          apply_assignments - applies specified feature assignments to source files
          docs - generates feature documentation
          for_feature - find assignment information for a feature
          for_file - find feature assignment for a single file
          test_coverage - generates per-feature test coverage statistics
          test_pyramid - generates per-feature test pyramid (unit, integration, regression) statistics
          additional_metrics - generates additional metrics per-feature (e.g. health score)
          validate - run all validations

          ##################################################
          help  - display help information about feature_map
          ##################################################
      EXPECTED
      expect(FeatureMap::Cli).to receive(:puts).with(expected)
      subject
    end
  end
end
