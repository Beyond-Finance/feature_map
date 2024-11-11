# typed: strict
# frozen_string_literal: true

require 'rubocop'
require 'sorbet-runtime'

module FeatureMap
  module Private
    class ComplexityCalculator
      extend T::Sig

      ComplexityMetrics = T.type_alias do
        T::Hash[
          String, # metric name
          Integer # score
        ]
      end

      sig { params(file_path: String).returns(ComplexityMetrics) }
      def self.calculate_for_file(file_path)
        return {} unless file_path.end_with?('.rb')

        file_content = File.read(file_path)
        # TODO: We're using internal RuboCop classes to calculate complexity metrics
        # for each file. Doing this tightly couples our functionality with RuboCop,
        # which does introduce some risk, should RuboCop decide to change the interface
        # of these classes. That being said, this is a tradeoff we're willing to
        # make right now.
        source = RuboCop::ProcessedSource.new(file_content, RUBY_VERSION.to_f)
        return {} unless source.ast

        abc_calculator = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.new(source.ast)
        # TODO: We plan to add more RuboCop metric calculations like Cyclomatic Complexity
        # and Perceived Complexity in future pull request(s)
        {
          'abc_size' => abc_calculator.calculate.first
        }
      end

      sig { params(file_paths: T::Array[String]).returns(T::Hash[String, Integer]) }
      def self.calculate_for_feature(file_paths)
        metrics = file_paths.map { |file| calculate_for_file(file) }
        return { 'abc_size' => 0 } if metrics.empty?

        total_abc = metrics.sum { |m| m['abc_size'] || 0 }

        {
          'abc_size' => total_abc
        }
      end
    end
  end
end
