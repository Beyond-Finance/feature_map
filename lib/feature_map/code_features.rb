# @feature Code Features
# frozen_string_literal: true

require 'yaml'
require 'csv'
require 'set'
require 'pathname'
require 'feature_map/code_features/plugin'
require 'feature_map/code_features/plugins/identity'

module FeatureMap
  module CodeFeatures
    NON_BREAKING_SPACE = 65_279.chr(Encoding::UTF_8)

    class IncorrectPublicApiUsageError < StandardError; end

    def self.all
      @all ||= from_csv('.feature_map/feature_definitions.csv')
      @all ||= for_directory('.feature_map/definitions')
    end

    def self.find(name)
      @index_by_name ||= begin
        result = {}
        all.each { |t| result[t.name] = t }
        result
      end

      @index_by_name[name]
    end

    def self.from_csv(file_path)
      return nil if !File.exist?(file_path)

      file_lines = File.readlines(file_path)
      # Remove any non-breaking space characters, as these can throw off the comment handling
      # and/or attribute key values.
      csv_content = file_lines.map { |line| line.gsub(NON_BREAKING_SPACE, '') }
                              .reject { |line| line.start_with?('#') }
                              .join.strip

      CSV.parse(csv_content, headers: true).map do |csv_row|
        feature_data = csv_row.to_h.transform_keys { |column_name| tag_value_for(column_name) }
        Feature.from_hash(feature_data)
      end
    end

    def self.for_directory(dir)
      Pathname.new(dir).glob('**/*.yml').map do |path|
        Feature.from_yml(path.to_s)
      rescue Psych::SyntaxError
        raise IncorrectPublicApiUsageError, "The YML in #{path} has a syntax error!"
      end
    end

    def self.validation_errors(features)
      Plugin.all_plugins.flat_map do |plugin|
        plugin.validation_errors(features)
      end
    end

    def self.tag_value_for(string)
      string.tr('&', ' ').gsub(/\s+/, '_').downcase
    end

    # Generally, you should not ever need to do this, because once your ruby process loads, cached content should not change.
    # Namely, the YML files that are the source of truth for features should not change, so we should not need to look at the YMLs again to verify.
    # The primary reason this is helpful is for tests where each context is testing against a different set of features
    def self.bust_caches!
      Plugin.bust_caches!
      @all = nil
      @index_by_name = nil
    end

    class Feature
      def self.from_yml(config_yml)
        hash = YAML.load_file(config_yml)

        new(
          config_yml: config_yml,
          raw_hash: hash
        )
      end

      def self.from_hash(raw_hash)
        new(
          config_yml: nil,
          raw_hash: raw_hash
        )
      end

      attr_reader :raw_hash
      attr_reader :config_yml

      def initialize(config_yml:, raw_hash:)
        @config_yml = config_yml
        @raw_hash = raw_hash
      end

      def name
        Plugins::Identity.for(self).identity.name
      end

      def to_tag
        CodeFeatures.tag_value_for(name)
      end

      def ==(other)
        if other.is_a?(CodeFeatures::Feature)
          name == other.name
        else
          false
        end
      end

      alias eql? ==

      def hash
        name.hash
      end
    end
  end
end
