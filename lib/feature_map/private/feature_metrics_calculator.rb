# typed: strict
# frozen_string_literal: true

require 'rubocop'
module FeatureMap
  module Private
    class FeatureMetricsCalculator
      extend T::Sig

      ABC_SIZE_METRIC = 'abc_size'
      CYCLOMATIC_COMPLEXITY_METRIC = 'cyclomatic_complexity'
      LINES_OF_CODE_METRIC = 'lines_of_code'
      TODO_LOCATIONS_METRIC = 'todo_locations'

      SUPPORTED_METRICS = T.let([
        ABC_SIZE_METRIC,
        CYCLOMATIC_COMPLEXITY_METRIC,
        LINES_OF_CODE_METRIC,
        TODO_LOCATIONS_METRIC
      ].freeze, T::Array[String])

      FeatureMetrics = T.type_alias do
        T::Hash[
          String, # metric name
          T.any(Integer, Float, T::Hash[String, String]) # score or todo locations with messages
        ]
      end

      sig { params(file_paths: T::Array[String]).returns(FeatureMetrics) }
      def self.calculate_for_feature(file_paths)
        metrics = file_paths.map { |file| calculate_for_file(file) }

        # Handle numeric metrics
        aggregate_metrics = SUPPORTED_METRICS.each_with_object({}) do |metric_key, agg|
          next if metric_key == TODO_LOCATIONS_METRIC

          agg[metric_key] = metrics.sum { |m| m[metric_key] || 0 }
        end

        # Merge all todo locations
        todo_locations = metrics.map { |m| m[TODO_LOCATIONS_METRIC] }.compact.reduce({}, :merge)
        aggregate_metrics[TODO_LOCATIONS_METRIC] = todo_locations

        aggregate_metrics
      end

      sig { params(file_path: String).returns(FeatureMetrics) }
      def self.calculate_for_file(file_path)
        metrics = {
          LINES_OF_CODE_METRIC => LinesOfCodeCalculator.new(file_path).calculate
        }

        return metrics unless file_path.end_with?('.rb')

        file_content = File.read(file_path)
        source = RuboCop::ProcessedSource.new(file_content, RUBY_VERSION.to_f)
        return metrics unless source.ast

        # NOTE: We're using some internal RuboCop classes to calculate complexity metrics
        # for each file. Doing this tightly couples our functionality with RuboCop,
        # which does introduce some risk, should RuboCop decide to change the interface
        # of these classes. That being said, this is a tradeoff we're willing to
        # make right now.
        abc_calculator = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.new(source.ast)
        cyclomatic_calculator = CyclomaticComplexityCalculator.new(source.ast)
        todo_locations = TodoInspector.new(file_path).calculate

        metrics.merge(
          ABC_SIZE_METRIC => abc_calculator.calculate.first.round(2),
          CYCLOMATIC_COMPLEXITY_METRIC => cyclomatic_calculator.calculate,
          TODO_LOCATIONS_METRIC => todo_locations
        )
      end
    end
  end
end
