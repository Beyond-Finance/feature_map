# typed: strict
# frozen_string_literal: true

require 'rubocop'
require 'sorbet-runtime'

module FeatureMap
  module Private
    class ComplexityCalculator
      extend T::Sig

      ABC_SIZE_METRIC = 'abc_size'
      LINES_OF_CODE_METRIC = 'lines_of_code'

      ComplexityMetrics = T.type_alias do
        T::Hash[
          String, # metric name
          Integer # score
        ]
      end

      sig { params(file_paths: T::Array[String]).returns(T::Hash[String, Integer]) }
      def self.calculate_for_feature(file_paths)
        metrics = file_paths.map { |file| calculate_for_file(file) }

        {
          ABC_SIZE_METRIC => metrics.sum { |m| m[ABC_SIZE_METRIC] || 0 },
          LINES_OF_CODE_METRIC => metrics.sum { |m| m[LINES_OF_CODE_METRIC] || 0 }
        }
      end

      sig { params(file_path: String).returns(ComplexityMetrics) }
      def self.calculate_for_file(file_path)
        return {} unless file_path.end_with?('.rb')

        file_content = File.read(file_path)
        file_metrics = T.let({ LINES_OF_CODE_METRIC => file_content.lines.count }, ComplexityMetrics)

        # TODO: We're using internal RuboCop classes to calculate complexity metrics
        # for each file. Doing this tightly couples our functionality with RuboCop,
        # which does introduce some risk, should RuboCop decide to change the interface
        # of these classes. That being said, this is a tradeoff we're willing to
        # make right now.
        source = RuboCop::ProcessedSource.new(file_content, RUBY_VERSION.to_f)
        return file_metrics unless source.ast

        abc_calculator = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.new(source.ast)

        # TODO: We plan to add more RuboCop metric calculations like Cyclomatic Complexity
        # and Perceived Complexity in future pull request(s)
        file_metrics.merge(ABC_SIZE_METRIC => abc_calculator.calculate.first)
      end

      # sig { params(file: String).returns(Integer) }
      # def self.count_lines_of_code(file)
      #   File.read(file).lines.count
      # end
    end
  end
end
