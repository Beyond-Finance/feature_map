# typed: strict

module FeatureMap
  module CodeFeatures
    # Plugins allow a client to add validation on custom keys in the feature YML.
    # For now, only a single plugin is allowed to manage validation on a top-level key.
    # In the future we can think of allowing plugins to be gracefully merged with each other.
    class Plugin
      extend T::Helpers
      extend T::Sig

      abstract!

      sig { params(feature: Feature).void }
      def initialize(feature)
        @feature = feature
      end

      sig { params(base: T.untyped).void }
      def self.inherited(base) # rubocop:disable Lint/MissingSuper
        all_plugins << T.cast(base, T.class_of(Plugin))
      end

      sig { returns(T::Array[T.class_of(Plugin)]) }
      def self.all_plugins
        @all_plugins ||= T.let(@all_plugins, T.nilable(T::Array[T.class_of(Plugin)]))
        @all_plugins ||= []
        @all_plugins
      end

      sig { params(features: T::Array[Feature]).returns(T::Array[String]) }
      def self.validation_errors(features)
        []
      end

      sig { params(feature: Feature).returns(T.attached_class) }
      def self.for(feature)
        register_feature(feature)
      end

      sig { params(feature: Feature, key: String).returns(String) }
      def self.missing_key_error_message(feature, key)
        "#{feature.name} is missing required key `#{key}`"
      end

      sig { returns(T::Hash[T.nilable(String), T::Hash[T.class_of(Plugin), Plugin]]) }
      def self.registry
        @registry ||= T.let(@registry, T.nilable(T::Hash[String, T::Hash[T.class_of(Plugin), Plugin]]))
        @registry ||= {}
        @registry
      end

      sig { params(feature: Feature).returns(T.attached_class) }
      def self.register_feature(feature)
        # We pull from the hash since `feature.name` uses the registry
        feature_name = feature.raw_hash['name']

        registry[feature_name] ||= {}
        registry_for_feature = registry[feature_name] || {}
        registry[feature_name] ||= {}
        registry_for_feature[self] ||= new(feature)
        T.unsafe(registry_for_feature[self])
      end

      sig { void }
      def self.bust_caches!
        all_plugins.each(&:clear_feature_registry!)
      end

      sig { void }
      def self.clear_feature_registry!
        @registry = nil
      end

      private_class_method :registry
      private_class_method :register_feature
    end
  end
end
