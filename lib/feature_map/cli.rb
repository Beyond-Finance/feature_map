# @feature Core Library
require 'optparse'
require 'pathname'
require 'fileutils'
require 'feature_map/output_color'

module FeatureMap
  class Cli
    def self.run!(argv)
      command = argv.shift
      if command == 'apply_assignments'
        apply_assignments!(argv)
      elsif command == 'validate'
        validate!(argv)
      elsif command == 'docs'
        docs!(argv)
      elsif command == 'test_coverage'
        test_coverage!(argv)
      elsif command == 'test_pyramid'
        test_pyramid!(argv)
      elsif command == 'additional_metrics'
        additional_metrics!(argv)
      elsif command == 'for_file'
        for_file(argv)
      elsif command == 'for_feature'
        for_feature(argv)
      elsif [nil, 'help'].include?(command)
        puts <<~USAGE
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
        USAGE
      else
        puts "'#{command}' is not a feature_map command. See `bin/featuremap help`."
      end
    end

    def self.apply_assignments!(argv)
      parser = OptionParser.new do |opts|
        opts.banner = <<~MSG
          Usage: bin/featuremap apply_assignments [assignments.csv].
          Note:  Expects two fields with no header:  dir/filepath,feature
                 Supports assignments in the following filetypes:
                   cls,html,js,jsx,rb,ts,tsx,xml
        MSG

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end
      args = parser.order!(argv)
      parser.parse!(args)
      non_flag_args = argv.reject { |arg| arg.start_with?('--') }
      assignments_file_path = non_flag_args[0]

      raise 'Please specify assignments.csv file' if assignments_file_path.nil?

      FeatureMap.apply_assignments!(assignments_file_path)
    end

    def self.validate!(argv)
      options = {}

      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: bin/featuremap validate [options]'

        opts.on('--skip-autocorrect', 'Skip automatically correcting any errors, such as the .feature_map/assignments.yml file') do
          options[:skip_autocorrect] = true
        end

        opts.on('-d', '--diff', 'Only run validations with staged files') do
          options[:diff] = true
        end

        opts.on('-s', '--skip-stage', 'Skips staging the .feature_map/assignments.yml file') do
          options[:skip_stage] = true
        end

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end
      args = parser.order!(argv)
      parser.parse!(args)

      files = if options[:diff]
                ENV.fetch('FEATUREMAP_GIT_STAGED_FILES') { `git diff --staged --name-only` }.split("\n").select do |file|
                  File.exist?(file)
                end
              else
                nil
              end

      FeatureMap.validate!(
        files: files,
        autocorrect: !options[:skip_autocorrect],
        stage_changes: !options[:skip_stage]
      )

      puts OutputColor.green('FeatureMap validation complete.')
    end

    def self.docs!(argv)
      options = {}

      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: bin/featuremap docs [options] [target_commit_sha]'

        opts.on('-s', '--skip-stage', 'Skips staging the .feature_map/assignments.yml file') do
          options[:skip_stage] = true
        end

        opts.on('--skip-validate', 'Skip the execution of the validate command, using the existing feature output files') do
          options[:skip_validate] = true
        end

        opts.on('--skip-additional-metrics', 'Skip the execution of the additional_metrics command, using the existing feature output files') do
          options[:skip_additional_metrics] = true
        end

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end
      args = parser.order!(argv)
      parser.parse!(args)

      non_flag_args = argv.reject { |arg| arg.start_with?('--') }
      custom_git_ref = non_flag_args[0]

      FeatureMap.validate!(stage_changes: !options[:skip_stage]) unless options[:skip_validate]
      FeatureMap.generate_additional_metrics! unless options[:skip_additional_metrics]

      FeatureMap.generate_docs!(custom_git_ref)

      puts OutputColor.green('FeatureMap documentaiton site generated.')
      puts 'Open .feature_map/docs/index.html in a browser to view the documentation site.'
    end

    def self.test_coverage!(argv)
      options = {
        source: :codecov,
        simplecov_paths: []
      }

      parser = OptionParser.new do |opts|
        opts.banner = <<~MSG
          Usage: bin/featuremap test_coverage [options] [code_cov_commit_sha].

          Options:
            --use-simplecov             Use SimpleCov instead of CodeCov
            --simplecov-path PATH       Path to a SimpleCov resultset.json file (can be specified multiple times)

          Note:#{'  '}
            - CodeCov mode requires environment variable `CODECOV_API_TOKEN`
            - CodeCov mode uses the provided commit SHA or defaults to the latest commit on main
            - SimpleCov mode requires at least one path to be specified with --simplecov-path
            - SimpleCov and CodeCov modes cannot be used together
        MSG

        opts.on('--use-simplecov', 'Use SimpleCov instead of CodeCov') do
          options[:source] = :simplecov
        end

        opts.on('--simplecov-path PATH', 'Use SimpleCov JSON resultset file instead of CodeCov.  May be specified multiple times.') do |path|
          options[:simplecov_paths] << path
        end

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end

      args = parser.order!(argv)
      parser.parse!(args)
      non_flag_args = argv.reject { |arg| arg.start_with?('--') }
      custom_commit_sha = non_flag_args[0]

      case options[:source]
      when :codecov
        code_cov_token = ENV.fetch('CODECOV_API_TOKEN', '')
        raise 'Please specify a CodeCov API token in your environment as `CODECOV_API_TOKEN`' if code_cov_token.empty?

        # If no commit SHA was provided in the CLI command args, use the most recent commit of the main branch in the upstream remote.
        commit_sha = custom_commit_sha || `git log -1 --format=%H origin/main`.chomp
        puts "Pulling test coverage statistics for commit #{commit_sha}"

        FeatureMap.gather_test_coverage!(commit_sha, code_cov_token)
      when :simplecov
        missing_paths = options[:simplecov_paths].reject { |path| File.exist?(path) }
        raise 'Error: When using --use-simplecov, you must specify at least one path with --simplecov-path.' if options[:simplecov_paths].empty?
        raise "SimpleCov results file not found: #{missing_paths.join(', ')}" if missing_paths.any?
        raise 'Error: Cannot specify a commit SHA when using --simplecov. These options are incompatible.' if custom_commit_sha

        puts "Gathering test coverage statistics from SimpleCov files: #{options[:simplecov_paths].join(', ')}"

        FeatureMap.gather_simplecov_test_coverage!(options[:simplecov_paths])
      else
        raise 'Invalid source'
      end

      puts OutputColor.green('FeatureMap test coverage statistics collected.')
      puts 'View the resulting test coverage for each feature in .feature_map/test-coverage.yml'
    end

    def self.test_pyramid!(argv)
      parser = OptionParser.new do |opts|
        opts.banner = <<~MSG
          Usage: bin/featuremap test_pyramid [unit_path] [integration_path] [regression_path] [regression_assignments_path].
          Paths should point to files containing json-formatted rspec test summaries.
          These can be generated via rspec's `-f j` flag.
          Regression test summary and assignments file path are optional.
        MSG

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end
      args = parser.order!(argv)
      parser.parse!(args)
      non_flag_args = argv.reject { |arg| arg.start_with?('--') }

      file_paths = non_flag_args.first(4)
      if file_paths.compact.size == 2
        unit_path, integration_path = file_paths
      elsif file_paths.compact.size == 4
        unit_path, integration_path, regression_path, regression_assignments_path = file_paths
      else
        raise 'Please specify at least the [unit_path] and [integration_path] arguments. If regression test details are provided both the [regression_path] and [regression_assignments_path] arguments must be populated.'
      end

      FeatureMap.generate_test_pyramid!(unit_path, integration_path, regression_path, regression_assignments_path)
    end

    def self.additional_metrics!(argv)
      parser = OptionParser.new do |opts|
        opts.banner = <<~MSG
          Usage: bin/featuremap additional_metrics
          Should be run after metrics and test coverage files have been generated
        MSG

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end
      args = parser.order!(argv)
      parser.parse!(args)

      FeatureMap.generate_additional_metrics!
    end

    # For now, this just returns feature assignment
    # Later, this could also return feature assignment errors about that file.
    def self.for_file(argv)
      options = {}

      # Long-term, we probably want to use something like `thor` so we don't have to implement logic
      # like this. In the short-term, this is a simple way for us to use the built-in OptionParser
      # while having an ergonomic CLI.
      files = argv.reject { |arg| arg.start_with?('--') }

      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: bin/featuremap for_file [options]'

        opts.on('--json', 'Output as JSON') do
          options[:json] = true
        end

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end
      args = parser.order!(argv)
      parser.parse!(args)

      if files.count != 1
        raise 'Please pass in one file. Use `bin/featuremap for_file --help` for more info'
      end

      feature = FeatureMap.for_file(files.first)

      feature_name = feature&.name || 'Unassigned'
      feature_yml = feature&.config_yml || 'Unassigned'

      if options[:json]
        json = {
          feature_name: feature_name,
          feature_yml: feature_yml
        }

        puts json.to_json
      else
        puts <<~MSG
          Feature: #{feature_name}
          Feature YML: #{feature_yml}
        MSG
      end
    end

    def self.for_feature(argv)
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: bin/featuremap for_feature \'Onboarding\''

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end
      features = argv.reject { |arg| arg.start_with?('--') }
      args = parser.order!(argv)
      parser.parse!(args)

      if features.count != 1
        raise 'Please pass in one feature. Use `bin/featuremap for_feature --help` for more info'
      end

      puts FeatureMap.for_feature(features.first)
    end

    private_class_method :validate!
  end
end
