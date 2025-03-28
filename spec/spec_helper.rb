# @feature Core Library
require 'simplecov'
require 'simplecov_json_formatter'
SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
SimpleCov.start

require 'bundler/setup'
require 'webmock/rspec'
require 'debug'
require 'rubocop'
require 'feature_map'
require 'packs-specification'
require 'packs/rspec/support' # Provides Rspec wrappers that support and isolate test files setup.
# See more at https://github.com/rubyatscale/packs-specification/blob/71336be896386c5527dac9aa935deb3ae3fe3828/lib/packs/rspec/support.rb#L3
require_relative 'support/application_fixtures'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context 'application fixtures'

  config.before do |c|
    allow_any_instance_of(FeatureMap.const_get(:Private)::Validations::FeaturesUpToDate).to receive(:`)
    allow(FeatureMap::Cli).to receive(:`)
    assignments_file_path.delete if assignments_file_path.exist?

    unless c.metadata[:do_not_bust_cache]
      FeatureMap.bust_caches!
      FeatureMap::CodeFeatures.bust_caches!
      CodeOwnership.bust_caches!
      CodeTeams.bust_caches!
    end
  end
end
