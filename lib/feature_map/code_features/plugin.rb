module FeatureMap
  module CodeFeatures
    # Plugins allow a client to add validation on custom keys in the feature YML.
    # For now, only a single plugin is allowed to manage validation on a top-level key.
    # In the future we can think of allowing plugins to be gracefully merged with each other.
    class Plugin
      def initialize(feature)
        @feature = feature
      end

      def self.inherited(base) # rubocop:disable Lint/MissingSuper
        all_plugins << base
      end

      def self.all_plugins
        @all_plugins ||= []
        @all_plugins
      end

      def self.validation_errors(features)
        []
      end

      def self.for(feature)
        register_feature(feature)
      end

      def self.missing_key_error_message(feature, key)
        "#{feature.name} is missing required key `#{key}`"
      end

      def self.registry
        @registry ||= {}
        @registry
      end

      def self.register_feature(feature)
        # We pull from the hash since `feature.name` uses the registry
        feature_name = feature.raw_hash['name']

        registry[feature_name] ||= {}
        registry_for_feature = registry[feature_name] || {}
        registry[feature_name] ||= {}
        registry_for_feature[self] ||= new(feature)
        registry_for_feature[self]
      end

      def self.bust_caches!
        all_plugins.each(&:clear_feature_registry!)
      end

      def self.clear_feature_registry!
        @registry = nil
      end

      private_class_method :registry
      private_class_method :register_feature
    end
  end
end
