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
    # with a single `feature-map-config.js` file containing content like the following:
    #   ```
    #   window.FEATURE_MAP_CONFIG = {
    #     environment: {
    #       "git_ref": "https://github.com/REPO/blob/GIT_SHA"
    #     },
    #     features: {
    #       "Foo": {
    #         "description": "The Foo feature with this sample application.",
    #         "dashboard_link": "https://example.com/dashbords/foo",
    #         "documentation_link": "https://example.com/docs/foo",
    #         "assignments": {
    #           "files": ["app/jobs/foo_job.rb", "app/lib/foo_service.rb"],
    #           "teams": ["team_a", "team_b"]
    #         },
    #         "metrics": {
    #           "abc_size": 12.34,
    #           "lines_of_code": 56,
    #           "cyclomatic_complexity": 7
    #         },
    #         "test_pyramid": {
    #           "unit_count": 100,
    #           "unit_pending": 12,
    #           "integration_count": 15,
    #           "integration_pending": 2,
    #           "regression_count": 6,
    #           "regression_pending": 0,
    #         }
    #       },
    #       "Bar": {
    #         "description": "Another feature within the application.",
    #         "dashboard_link": "https://example.com/docs/bar",
    #         "documentation_link": "https://example.com/dashbords/bar",
    #         "assignments":{
    #           "files": ["app/controllers/bar_controller.rb", "app/lib/bar_service.rb"],
    #           "teams": ["team_a"]
    #         },
    #         "metrics": {
    #           "abc_size": 98.76,
    #           "lines_of_code": 54,
    #           "cyclomatic_complexity": 32
    #         },
    #         "test_pyramid": null
    #       }
    #     },
    #     project: {
    #       ...values from ./feature_map/config.yml
    #     }
    #   };
    #   ```
    # The `window.FEATURES` global variable is used within the site logic to render an appropriate set of
    # documentation artifacts and charts.
    class DocumentationSite
      ASSETS_DIRECTORY = 'docs'
      FETAURE_DEFINITION_KEYS_TO_INCLUDE = %w[description dashboard_link documentation_link].freeze

      def self.generate(
        feature_assignments,
        feature_metrics,
        feature_test_coverage,
        feature_test_pyramid,
        feature_additional_metrics,
        project_configuration,
        git_ref
      )
        FileUtils.mkdir_p(output_directory) if !output_directory.exist?

        features = feature_assignments.keys.each_with_object({}) do |feature_name, hash|
          feature_definition = CodeFeatures.find(feature_name)
          hash[feature_name] = feature_definition&.raw_hash&.slice(*FETAURE_DEFINITION_KEYS_TO_INCLUDE) || {}
          hash[feature_name].merge!(
            assignments: feature_assignments[feature_name],
            metrics: feature_metrics[feature_name],
            test_coverage: feature_test_coverage[feature_name],
            test_pyramid: feature_test_pyramid[feature_name],
            additional_metrics: feature_additional_metrics[feature_name]
          )
        end

        environment = {
          git_ref: git_ref
        }
        feature_map_config = {
          features: features,
          environment: environment,
          project: project_configuration
        }.to_json
        output_directory.join('feature-map-config.js').write("window.FEATURE_MAP_CONFIG = #{feature_map_config};")

        Dir.each_child(assets_directory) do |file_name|
          FileUtils.cp(File.join(assets_directory, file_name), output_directory.join(file_name))
        end
      end

      def self.output_directory
        Pathname.pwd.join('.feature_map/docs')
      end

      def self.assets_directory
        File.join(File.dirname(__FILE__), ASSETS_DIRECTORY)
      end
    end
  end
end
