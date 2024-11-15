# frozen_string_literal: true

# typed: strict

require 'yaml'
require 'set'
require 'pathname'
require 'feature_map/code_features/plugin'
require 'feature_map/code_features/plugins/identity'

module FeatureMap
  module CodeFeatures
    extend T::Sig

    class IncorrectPublicApiUsageError < StandardError; end

    sig { returns(T::Array[Feature]) }
    def self.all
      @all = T.let(@all, T.nilable(T::Array[Feature]))
      @all ||= for_directory('.feature_map/definitions')
    end

    sig { params(name: String).returns(T.nilable(Feature)) }
    def self.find(name)
      @index_by_name = T.let(@index_by_name, T.nilable(T::Hash[String, CodeFeatures::Feature]))
      @index_by_name ||= begin
        result = {}
        all.each { |t| result[t.name] = t }
        result
      end

      @index_by_name[name]
    end

    sig { params(dir: String).returns(T::Array[Feature]) }
    def self.for_directory(dir)
      Pathname.new(dir).glob('**/*.yml').map do |path|
        Feature.from_yml(path.to_s)
      rescue Psych::SyntaxError
        raise IncorrectPublicApiUsageError, "The YML in #{path} has a syntax error!"
      end
    end

    sig { params(features: T::Array[Feature]).returns(T::Array[String]) }
    def self.validation_errors(features)
      Plugin.all_plugins.flat_map do |plugin|
        plugin.validation_errors(features)
      end
    end

    sig { params(string: String).returns(String) }
    def self.tag_value_for(string)
      string.tr('&', ' ').gsub(/\s+/, '_').downcase
    end

    # Generally, you should not ever need to do this, because once your ruby process loads, cached content should not change.
    # Namely, the YML files that are the source of truth for features should not change, so we should not need to look at the YMLs again to verify.
    # The primary reason this is helpful is for tests where each context is testing against a different set of features
    sig { void }
    def self.bust_caches!
      Plugin.bust_caches!
      @all = nil
      @index_by_name = nil
    end

    class Feature
      extend T::Sig

      sig { params(config_yml: String).returns(Feature) }
      def self.from_yml(config_yml)
        hash = YAML.load_file(config_yml)

        new(
          config_yml: config_yml,
          raw_hash: hash
        )
      end

      sig { params(raw_hash: T::Hash[T.untyped, T.untyped]).returns(Feature) }
      def self.from_hash(raw_hash)
        new(
          config_yml: nil,
          raw_hash: raw_hash
        )
      end

      sig { returns(T::Hash[T.untyped, T.untyped]) }
      attr_reader :raw_hash

      sig { returns(T.nilable(String)) }
      attr_reader :config_yml

      sig do
        params(
          config_yml: T.nilable(String),
          raw_hash: T::Hash[T.untyped, T.untyped]
        ).void
      end
      def initialize(config_yml:, raw_hash:)
        @config_yml = config_yml
        @raw_hash = raw_hash
      end

      sig { returns(String) }
      def name
        Plugins::Identity.for(self).identity.name
      end

      sig { returns(String) }
      def to_tag
        CodeFeatures.tag_value_for(name)
      end

      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        if other.is_a?(CodeFeatures::Feature)
          name == other.name
        else
          false
        end
      end

      alias eql? ==

      sig { returns(Integer) }
      def hash
        name.hash
      end
    end
  end
end
