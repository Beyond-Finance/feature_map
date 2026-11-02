# @feature Core Library
module FeatureMap
  RSpec.describe Configuration do
    describe '.fetch' do
      it 'evaluates ERB in the config file' do
        write_configuration('repository' => { 'url' => "<%= ENV.fetch('FEATURE_MAP_SPEC_URL', 'https://example.com/default') %>" })

        expect(Configuration.fetch.repository['url']).to eq 'https://example.com/default'
      end

      it 'reads environment variables through ERB' do
        write_configuration('repository' => { 'url' => "<%= ENV.fetch('FEATURE_MAP_SPEC_URL', '') %>" })

        stub_const('ENV', ENV.to_h.merge('FEATURE_MAP_SPEC_URL' => 'https://example.com/from-env'))

        expect(Configuration.fetch.repository['url']).to eq 'https://example.com/from-env'
      end

      it 'keeps the command sections out of the general config hash' do
        write_configuration(
          'repository' => { 'url' => 'https://example.com' },
          'github_pr_annotation' => { 'github_token' => 'secret-a' },
          'slack_release_log' => { 'slack_api_token' => 'secret-b' },
          'slack_team_notifications' => { 'teams' => { 'Sales' => 'secret-c' } }
        )

        configuration = Configuration.fetch

        expect(configuration.raw_hash.keys).not_to include(*Configuration::COMMAND_SECTIONS)
        expect(configuration.command_sections).to eq(
          'github_pr_annotation' => { 'github_token' => 'secret-a' },
          'slack_release_log' => { 'slack_api_token' => 'secret-b' },
          'slack_team_notifications' => { 'teams' => { 'Sales' => 'secret-c' } }
        )
      end

      it 'returns no command sections when none are configured' do
        write_configuration

        expect(Configuration.fetch.command_sections).to eq({})
      end
    end
  end
end
