# typed: strict
# frozen_string_literal: true

module FeatureMap
  module Private
    #
    # This class is responsible for generating a standalone site that provides documentation of the features
    # defined within a given application. This site consists of precompiled HTML, JS, and CSS content that
    # is combined with a JSON file containing the assignment and metrics information about all application
    # features.
    #
    class DocumentationSite
      extend T::Sig

      ASSETS_DIRECTORY = 'documentation_site_assets'

      sig { params(feature_assignments: AssignmentsFile::FeaturesContent, feature_metrics: MetricsFile::FeaturesContent).void }
      def self.generate(feature_assignments, feature_metrics)
        FileUtils.mkdir_p(output_directory) if !output_directory.exist?

        features = CodeFeatures.all.each_with_object({}) do |feature, hash|
          hash[feature.name] = {
            assignments: feature_assignments[feature.name],
            metrics: feature_metrics[feature.name]
          }
        end

        output_directory.join('features.js').write("window.FEATURES = #{features.to_json};")

        Dir.each_child(assets_directory) do |file_name|
          FileUtils.cp(File.join(assets_directory, file_name), output_directory.join(file_name))
        end
      end

      sig { returns(Pathname) }
      def self.output_directory
        Pathname.pwd.join('.feature_map/docs')
      end

      sig { returns(String) }
      def self.assets_directory
        File.join(File.dirname(__FILE__), ASSETS_DIRECTORY)
      end
    end
  end
end
