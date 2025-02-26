# frozen_string_literal: true

module FeatureMap
  module Private
    class PercentileMetricsCalculator
      attr_reader :metrics, :test_coverage

      def initialize(metrics:, test_coverage:)
        @metrics = metrics
        @test_coverage = test_coverage
      end

      def cyclomatic_complexity_for(feature_name)
        calculate(
          cyclomatic_complexity_ratios,
          metrics.dig(feature_name, FeatureMetricsCalculator::COMPLEXITY_RATIO_METRIC) || 0
        )
      end

      def encapsulation_for(feature_name)
        calculate(
          encapsulation_ratios,
          metrics.dig(feature_name, FeatureMetricsCalculator::ENCAPSULATION_RATIO_METRIC) || 0
        )
      end

      def feature_size_for(feature_name)
        calculate(
          feature_sizes,
          metrics.dig(feature_name, FeatureMetricsCalculator::LINES_OF_CODE_METRIC) || 0
        )
      end

      def test_coverage_for(feature_name)
        calculate(
          test_coverage_ratios,
          test_coverage.dig(feature_name, TestCoverageFile::COVERAGE_RATIO) || 0
        )
      end

      private

      def calculate(collection, score)
        max = collection.max || 0
        percentile = percentile_of(collection, score)
        percent_of_max = max.zero? ? 0 : ((score.to_f / max) * 100).round.to_i

        { 'percentile' => percentile, 'percent_of_max' => percent_of_max, 'score' => score }
      end

      def cyclomatic_complexity_ratios
        return @cyclomatic_complexity_ratios if defined?(@cyclomatic_complexity_ratios)

        @cyclomatic_complexity_ratios = metrics.values.map { |m| m[FeatureMetricsCalculator::COMPLEXITY_RATIO_METRIC] }.compact
      end

      def encapsulation_ratios
        return @encapsulation_ratios if defined?(@encapsulation_ratios)

        @encapsulation_ratios = metrics.values.map { |m| m[FeatureMetricsCalculator::ENCAPSULATION_RATIO_METRIC] }.compact
      end

      def feature_sizes
        return @feature_sizes if defined?(@feature_sizes)

        @feature_sizes = metrics.values.map { |m| m[FeatureMetricsCalculator::LINES_OF_CODE_METRIC] }.compact
      end

      # NOTE:  This percentile calculation uses a midpoint convention for handling ties,
      # where values equal to the target contribute 0.5 to the count.
      # This approach considers each value as being "half below and half above" itself,
      # resulting in the maximum value in a dataset having a percentile of (n-0.5)/n * 100
      # instead of 100%.
      def percentile_of(arr, val)
        return 0.0 if arr.empty?

        ensure_array_of_floats = arr.map(&:to_f)
        ensure_float_value = val.to_f

        below_or_equal_count = ensure_array_of_floats.reduce(0) do |acc, v|
          if v < ensure_float_value
            acc + 1
          elsif v == ensure_float_value
            acc + 0.5
          else
            acc
          end
        end

        ((100 * below_or_equal_count) / ensure_array_of_floats.length).to_f
      end

      def test_coverage_ratios
        return @test_coverage_ratios if defined?(@test_coverage_ratios)

        @test_coverage_ratios = test_coverage.values.map { |c| c[TestCoverageFile::COVERAGE_RATIO] }.compact
      end
    end
  end
end
