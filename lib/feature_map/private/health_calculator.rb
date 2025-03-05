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
          cyclomatic_complexity_config['percent_of_max_threshold']
        )
      end

      def encapsulation_component_for(feature_name)
        encapsulation = percentile_metrics.encapsulation_for(feature_name)

        health_score_component(
          encapsulation_config['weight'],
          encapsulation['percentile'],
          encapsulation['percent_of_max'],
          encapsulation_config['percent_of_max_threshold']
        )
      end

      def health_score_component(awardable_points, score, percent_of_max, percent_of_max_threshold)
        close_to_maximum_score = percent_of_max_threshold && percent_of_max >= percent_of_max_threshold
        component = { 'awardable_points' => awardable_points, 'close_to_maximum_score' => close_to_maximum_score }

        # NOTE:  Certain metrics scores are derived from their relative percentile.
        #        As a codebase converges, say on encapsulation, relative percentile
        #        scoring dictates that the lower percentiles always receive a
        #        worse score than higher percentiles even when their values are close.
        #
        #        E.g., if encapsulation scores are of the set [9.6, 9.7, 9.8, 9.9],
        #        is it fair to award the feature at `9.6` dramatically less than `9.9?`
        #
        #        Each host application can set a `percent_of_max_threshold` for these metrics such that
        #        if a given feature's score is within this threshold of the highest performing feature,
        #        it is awarded full points.
        return component.merge('health_score' => awardable_points) if close_to_maximum_score

        component.merge(
          'health_score' => [(score.to_f / 100) * awardable_points, awardable_points].min
        )
      end

      def test_coverage_component_for(feature_name)
        test_coverage = percentile_metrics.test_coverage_for(feature_name)

        # NOTE:  Test coverage is based on the absolute coverage percentage
        #        of code within a given feature.  E.g., a score of 60 does not indicate
        #        that test coverage is within the sixtieth percentile -- but rather
        #        that 60% of its lines are covered by tests.
        #
        #        FeatureMap does not mean to imply that all codebases should seek to
        #        cover 100% of lines, so `percent_of_max_threshold` in this case is the variance
        #        from 100% test coverage which should receive full marks.
        health_score_component(
          test_coverage_config['weight'],
          test_coverage['score'],
          test_coverage['score'],
          test_coverage_config['percent_of_max_threshold']
        )
      end
    end
  end
end
