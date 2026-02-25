# @feature Metrics Calculation
# frozen_string_literal: true

module FeatureMap
  module Private
    class FeatureMetricsCalculator
      ABC_SIZE_METRIC = 'abc_size'
      CYCLOMATIC_COMPLEXITY_METRIC = 'cyclomatic_complexity'
      LINES_OF_CODE_METRIC = 'lines_of_code'
      TODO_LOCATIONS_METRIC = 'todo_locations'
      COMPLEXITY_RATIO_METRIC = 'complexity_ratio'
      ENCAPSULATION_RATIO_METRIC = 'encapsulation_ratio'

      SUPPORTED_METRICS = [
        ABC_SIZE_METRIC,
        CYCLOMATIC_COMPLEXITY_METRIC,
        LINES_OF_CODE_METRIC,
        TODO_LOCATIONS_METRIC,
        COMPLEXITY_RATIO_METRIC,
        ENCAPSULATION_RATIO_METRIC
      ].freeze

      def self.calculate_for_feature(file_paths)
        metrics = file_paths.map { |file| calculate_for_file(file) }

        # Handle numeric metrics
        aggregate_metrics = [ABC_SIZE_METRIC, CYCLOMATIC_COMPLEXITY_METRIC, LINES_OF_CODE_METRIC].each_with_object({}) do |metric_key, agg|
          agg[metric_key] = metrics.sum { |m| m[metric_key] || 0 }
        end

        # Handle additional supported metrics
        todo_locations = metrics.map { |m| m[TODO_LOCATIONS_METRIC] }.compact.reduce({}, :merge)
        aggregate_metrics[TODO_LOCATIONS_METRIC] = todo_locations
        aggregate_metrics[COMPLEXITY_RATIO_METRIC] = complexity_ratio(aggregate_metrics)
        aggregate_metrics[ENCAPSULATION_RATIO_METRIC] = encapsulation_ratio(file_paths, aggregate_metrics)

        aggregate_metrics
      end

      def self.calculate_for_file(file_path)
        metrics = {
          LINES_OF_CODE_METRIC => LinesOfCodeCalculator.new(file_path).calculate,
          TODO_LOCATIONS_METRIC => TodoInspector.new(file_path).calculate

        }

        return metrics unless file_path.end_with?('.rb')

        # Lazy load the rubocop gem only when we need to process AST nodes to avoid introducing unnecessary
        # dependencies for use cases that do not exercise this functionality.
        require 'rubocop'

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

        metrics.merge(
          ABC_SIZE_METRIC => abc_calculator.calculate.first.round(2),
          CYCLOMATIC_COMPLEXITY_METRIC => cyclomatic_calculator.calculate
        )
      end

      def self.complexity_ratio(aggregate_metrics)
        return 0.0 if aggregate_metrics[LINES_OF_CODE_METRIC].nil? || aggregate_metrics[CYCLOMATIC_COMPLEXITY_METRIC].nil? || aggregate_metrics[CYCLOMATIC_COMPLEXITY_METRIC].zero?

        aggregate_metrics[LINES_OF_CODE_METRIC].to_f / aggregate_metrics[CYCLOMATIC_COMPLEXITY_METRIC]
      end

      def self.encapsulation_ratio(file_paths, aggregate_metrics)
        return 0.0 if file_paths.nil? || aggregate_metrics[LINES_OF_CODE_METRIC].nil? || aggregate_metrics[LINES_OF_CODE_METRIC].zero?

        file_paths.length.to_f / aggregate_metrics[LINES_OF_CODE_METRIC]
      end
    end
  end
end
