# typed: strict
# frozen_string_literal: true

require 'rubocop'

module FeatureMap
  module Private
    class FeatureMetricsCalculator
      extend T::Sig

      ABC_SIZE_METRIC = 'abc_size'
      LINES_OF_CODE_METRIC = 'lines_of_code'
      CYCLOMATIC_COMPLEXITY_METRIC = 'cyclomatic_complexity'

      SUPPORTED_METRICS = T.let([
        ABC_SIZE_METRIC,
        LINES_OF_CODE_METRIC,
        CYCLOMATIC_COMPLEXITY_METRIC
      ].freeze, T::Array[String])

      FeatureMetrics = T.type_alias do
        T::Hash[
          String, # metric name
          Integer # score
        ]
      end

      sig { params(file_paths: T::Array[String]).returns(FeatureMetrics) }
      def self.calculate_for_feature(file_paths)
        metrics = file_paths.map { |file| calculate_for_file(file) }

        SUPPORTED_METRICS.each_with_object({}) do |metric_key, aggregate_metrics|
          aggregate_metrics[metric_key] = metrics.sum { |m| m[metric_key] || 0 }
        end
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

        metrics.merge(
          ABC_SIZE_METRIC => abc_calculator.calculate.first.round(2),
          CYCLOMATIC_COMPLEXITY_METRIC => cyclomatic_calculator.calculate
        )
      end
    end
  end
end
