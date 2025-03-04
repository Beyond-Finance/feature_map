# frozen_string_literal: true

module FeatureMap
  module Private
    class HealthCalculator
      attr_reader :percentile_metrics, :cyclomatic_complexity_config, :encapsulation_config, :test_coverage_config

      def initialize(percentile_metrics:, health_config:)
        @percentile_metrics = percentile_metrics
        @cyclomatic_complexity_config = health_config['components']['cyclomatic_complexity']
        @encapsulation_config = health_config['components']['encapsulation']
        @test_coverage_config = health_config['components']['test_coverage']
      end

      def health_score_for(feature_name)
        test_coverage_component = test_coverage_component_for(feature_name)
        cyclomatic_complexity_component = cyclomatic_complexity_component_for(feature_name)
        encapsulation_component = encapsulation_component_for(feature_name)

        overall = [
          test_coverage_component,
          cyclomatic_complexity_component,
          encapsulation_component
        ].sum { |c| c['health_score'] }

        {
          'test_coverage_component' => test_coverage_component,
          'cyclomatic_complexity_component' => cyclomatic_complexity_component,
          'encapsulation_component' => encapsulation_component,
          'overall' => overall
        }
      end

      private

      def cyclomatic_complexity_component_for(feature_name)
        cyclomatic_complexity = percentile_metrics.cyclomatic_complexity_for(feature_name)

        health_score_component(
          cyclomatic_complexity_config['weight'],
          cyclomatic_complexity['percentile'],
          cyclomatic_complexity['percent_of_max'],
          100 - cyclomatic_complexity_config['minimum_variance']
        )
      end

      def encapsulation_component_for(feature_name)
        encapsulation = percentile_metrics.encapsulation_for(feature_name)

        health_score_component(
          encapsulation_config['weight'],
          encapsulation['percentile'],
          encapsulation['percent_of_max'],
          100 - encapsulation_config['minimum_variance']
        )
      end

      def health_score_component(awardable_points, score, percent_of_max = 0, percent_of_max_threshold = 100)
        close_to_maximum_score = percent_of_max >= percent_of_max_threshold

        if close_to_maximum_score
          {
            'awardable_points' => awardable_points,
            'health_score' => awardable_points,
            'close_to_maximum_score' => close_to_maximum_score
          }
        else
          {
            'awardable_points' => awardable_points,
            'health_score' => [(score.to_f / 100) * awardable_points, awardable_points].min,
            'close_to_maximum_score' => close_to_maximum_score
          }
        end
      end

      def test_coverage_component_for(feature_name)
        test_coverage = percentile_metrics.test_coverage_for(feature_name)

        health_score_component(
          test_coverage_config['weight'],
          test_coverage['score']
        )
      end
    end
  end
end
