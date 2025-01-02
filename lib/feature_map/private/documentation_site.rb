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
    # The code within the `docs` directory is directly copied into an output directory and combined
    # with a single `features.js` file containing content like the following:
    #   ```
    #   window.FEATURES = {
    #     "Foo": {
    #       "assignments": {
    #         "files": ["app/jobs/foo_job.rb", "app/lib/foo_service.rb"],
    #         "teams": ["team_a", "team_b"]
    #       },
    #       "metrics": {
    #         "abc_size": 12.34,
    #         "lines_of_code": 56,
    #         "cyclomatic_complexity": 7
    #       }
    #     },
    #     "Bar": {
    #       "assignments":{
    #         "files": ["app/controllers/bar_controller.rb", "app/lib/bar_service.rb"],
    #         "teams": ["team_a"]
    #       },
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

      ASSETS_DIRECTORY = 'docs'

      sig { params(feature_assignments: AssignmentsFile::FeaturesContent, feature_metrics: MetricsFile::FeaturesContent, feature_test_coverage: TestCoverageFile::FeaturesContent).void }
      def self.generate(feature_assignments, feature_metrics, feature_test_coverage)
        FileUtils.mkdir_p(output_directory) if !output_directory.exist?

        features = feature_assignments.keys.each_with_object({}) do |feature_name, hash|
          hash[feature_name] = {
            assignments: feature_assignments[feature_name],
            metrics: feature_metrics[feature_name],
            test_coverage: feature_test_coverage[feature_name]
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
