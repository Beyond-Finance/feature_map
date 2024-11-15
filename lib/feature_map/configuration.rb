# typed: strict

module FeatureMap
  class Configuration < T::Struct
    extend T::Sig

    const :assigned_globs, T::Array[String]
    const :unassigned_globs, T::Array[String]
    const :unbuilt_gems_path, T.nilable(String)
    const :skip_features_validation, T::Boolean
    const :raw_hash, T::Hash[T.untyped, T.untyped]
    const :require_assignment_for_teams, T.nilable(T::Array[String])

    sig { returns(Configuration) }
    def self.fetch
      config_hash = YAML.load_file('.feature_map/config.yml')

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
        require_assignment_for_teams: config_hash.fetch('require_assignment_for_teams', nil)
      )
    end
  end
end
