# typed: strict
# frozen_string_literal: true

module FeatureMap
  module Private
    #
    # This class is responsible for turning FeatureMap directives (e.g. annotations, directory assignments, etc)
    # into a metrics.yml file, that can be used as an input to a variety of engineering team utilities (e.g.
    # PR/release announcements, documentation generation, etc).
    #
    class MetricsFile
      extend T::Sig

      class FileContentError < StandardError; end

      FEATURES_KEY = 'features'

      FeatureName = T.type_alias { String }

      FeatureMetrics = T.type_alias do
        T::Hash[
          String,
          Integer
        ]
      end

      FeaturesContent = T.type_alias do
        T::Hash[
          FeatureName,
          FeatureMetrics
        ]
      end

      sig { void }
      def self.write!
        FileUtils.mkdir_p(path.dirname) if !path.dirname.exist?

        path.write([header_comment, "\n", generate_content.to_yaml].join)
      end

      sig { returns(Pathname) }
      def self.path
        Pathname.pwd.join('.feature_map/metrics.yml')
      end

      sig { returns(String) }
      def self.header_comment
        <<~HEADER
          # STOP! - DO NOT EDIT THIS FILE MANUALLY
          # This file was automatically generated by "bin/featuremap validate". The next time this file
          # is generated any changes will be lost. For more details:
          # https://github.com/Beyond-Finance/feature_map
          #
          # It is NOT recommended to commit this file into your source control. It will change as a
          # result of nearly all other source code changes. This file should be ignored by your source
          # control but can be used for other feature analysis operations (e.g. documentation
          # generation, etc).
        HEADER
      end

      sig { returns(T::Hash[String, FeaturesContent]) }
      def self.generate_content
        feature_metrics = T.let({}, FeaturesContent)

        Private.feature_file_assignments.each do |feature_name, files|
          feature_metrics[feature_name] = FeatureMetricsCalculator.calculate_for_feature(files)
        end

        { FEATURES_KEY => feature_metrics }
      end

      sig { returns(FeaturesContent) }
      def self.load_features!
        metrics_content = YAML.load_file(path)

        return metrics_content[FEATURES_KEY] if metrics_content.is_a?(Hash) && metrics_content[FEATURES_KEY]

        raise FileContentError, "Unexpected content found in #{path}. Use `bin/featuremap validate` to regenerate it and try again."
      rescue Psych::SyntaxError => e
        raise FileContentError, "Invalid YAML content found at #{path}. Error: #{e.message} Use `bin/featuremap validate` to generate it and try again."
      rescue Errno::ENOENT
        raise FileContentError, "No feature metrics file found at #{path}. Use `bin/featuremap validate` to generate it and try again."
      end
    end
  end
end
