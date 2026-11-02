# @feature Core Library
require 'erb'

module FeatureMap
  class Configuration
    COMMAND_SECTIONS = %w[github_pr_annotation slack_release_log slack_team_notifications].freeze

    attr_reader :assigned_globs
    attr_reader :unassigned_globs
    attr_reader :unbuilt_gems_path
    attr_reader :skip_features_validation
    attr_reader :raw_hash
    attr_reader :skip_code_ownership
    attr_reader :require_assignment_for_teams
    attr_reader :ignore_feature_definitions
    attr_reader :code_cov
    attr_reader :repository
    attr_reader :documentation_site
    attr_reader :documentation_site_url
    attr_reader :command_sections

    def initialize(
      assigned_globs: nil,
      unassigned_globs: nil,
      unbuilt_gems_path: nil,
      skip_features_validation: nil,
      raw_hash: nil,
      skip_code_ownership: nil,
      require_assignment_for_teams: nil,
      ignore_feature_definitions: nil,
      code_cov: nil,
      repository: nil,
      documentation_site: nil,
      documentation_site_url: nil,
      command_sections: nil
    )
      @assigned_globs = assigned_globs
      @unassigned_globs = unassigned_globs
      @unbuilt_gems_path = unbuilt_gems_path
      @skip_features_validation = skip_features_validation
      @raw_hash = raw_hash
      @skip_code_ownership = skip_code_ownership
      @require_assignment_for_teams = require_assignment_for_teams
      @ignore_feature_definitions = ignore_feature_definitions
      @code_cov = code_cov
      @repository = repository
      @documentation_site = documentation_site
      @documentation_site_url = documentation_site_url
      @command_sections = command_sections || {}
    end

    def self.fetch
      full_hash = YAML.load(ERB.new(File.read('.feature_map/config.yml')).result) || {}
      command_sections = full_hash.slice(*COMMAND_SECTIONS)
      config_hash = full_hash.except(*COMMAND_SECTIONS)

      if config_hash.key?('require')
        config_hash['require'].each do |require_directive|
          Private::ExtensionLoader.load(require_directive)
        end
      end

      new(
        assigned_globs: config_hash.fetch('assigned_globs', []),
        unassigned_globs: config_hash.fetch('unassigned_globs', []),
        skip_features_validation: config_hash.fetch('skip_features_validation', false),
        raw_hash: config_hash,
        skip_code_ownership: config_hash.fetch('skip_code_ownership', true),
        require_assignment_for_teams: config_hash.fetch('require_assignment_for_teams', nil),
        ignore_feature_definitions: config_hash.fetch('ignore_feature_definitions', false),
        code_cov: config_hash.fetch('code_cov', {}),
        repository: config_hash.fetch('repository', {}),
        documentation_site: config_hash.fetch('documentation_site', {}),
        documentation_site_url: config_hash.fetch('documentation_site_url', nil),
        command_sections: command_sections
      )
    end
  end
end
