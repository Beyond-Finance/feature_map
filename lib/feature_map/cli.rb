# typed: true

require 'optparse'
require 'pathname'
require 'fileutils'
require 'feature_map/output_color'

module FeatureMap
  class Cli
    def self.run!(argv)
      command = argv.shift
      if command == 'validate'
        validate!(argv)
      elsif command == 'docs'
        docs!(argv)
      elsif command == 'test_coverage'
        test_coverage!(argv)
      elsif command == 'for_file'
        for_file(argv)
      elsif command == 'for_feature'
        for_feature(argv)
      elsif [nil, 'help'].include?(command)
        puts <<~USAGE
          Usage: bin/featuremap <subcommand>

          Subcommands:
            validate - run all validations
            docs - generates feature documentation
            test_coverage - generates per-feature test coverage statistics
            for_file - find feature assignment for a single file
            for_feature - find assignment information for a feature
            help  - display help information about feature_map
        USAGE
      else
        puts "'#{command}' is not a feature_map command. See `bin/featuremap help`."
      end
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
        opts.banner = 'Usage: bin/featuremap docs [options]'

        opts.on('-s', '--skip-stage', 'Skips staging the .feature_map/assignments.yml file') do
          options[:skip_stage] = true
        end

        opts.on('--skip-validate', 'Skip the execution of the validate command, using the existing feature output files') do
          options[:skip_validate] = true
        end

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end
      args = parser.order!(argv)
      parser.parse!(args)

      FeatureMap.validate!(stage_changes: !options[:skip_stage]) unless options[:skip_validate]

      FeatureMap.generate_docs!

      puts OutputColor.green('FeatureMap documentaiton site generated.')
      puts 'Open .feature_map/docs/index.html in a browser to view the documentation site.'
    end

    def self.test_coverage!(argv)
      parser = OptionParser.new do |opts|
        opts.banner = <<~MSG
          Usage: bin/featuremap test_coverage [options] [code_cov_commit_sha].
          Note:  Requires environment variable `CODECOV_TOKEN`.
        MSG

        opts.on('--help', 'Shows this prompt') do
          puts opts
          exit
        end
      end
      args = parser.order!(argv)
      parser.parse!(args)
      non_flag_args = argv.reject { |arg| arg.start_with?('--') }
      custom_commit_sha = non_flag_args[0]

      code_cov_token = ENV.fetch('CODECOV_TOKEN', '')
      raise 'Please specify a CodeCov API token in your environment as `CODECOV_TOKEN`' if code_cov_token.empty?

      # If no commit SHA was providid in the CLI command args, use the most recent commit of the main branch in the upstream remote.
      commit_sha = custom_commit_sha || `git log -1 --format=%H origin/main`.chomp
      puts "Pulling test coverage statistics for commit #{commit_sha}"

      FeatureMap.gather_test_coverage!(commit_sha, code_cov_token)

      puts OutputColor.green('FeatureMap test coverage statistics collected.')
      puts 'View the resulting test coverage for each feature in .feature_map/test-coverage.yml'
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
