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
    # The HTML, JS, and CSS files within the `documentation_site_assets` directory are directly copied into
    # output directory and combined with a single `features_js` file containing content like the following:
    #   ```
    #   window.FEATURES = {
    #     "Foo": {
    #       "assignments": ["app/jobs/foo_job.rb", "app/lib/foo_service.rb"],
    #       "metrics": {
    #         "abc_size": 12.34,
    #         "lines_of_code": 56,
    #         "cyclomatic_complexity": 7
    #       }
    #     },
    #     "Bar": {
    #       "assignments": ["app/controllers/bar_controller.rb", "app/lib/bar_service.rb"],
    #       "metrics": {
    #         "abc_size": 98.76,
    #         "lines_of_code": 54,
    #         "cyclomatic_complexity": 32
    #       }
    #     }
    #   };
    #   ```
    # The `window.FEATURES` global variable is used within the site logic to render an appropriate set of
    # documentation artifacts and charts.
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
