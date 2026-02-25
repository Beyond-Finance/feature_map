# @feature Metrics Calculation
# frozen_string_literal: true

module FeatureMap
  module Private
    class CyclomaticComplexityCalculator
      COMPLEXITY_NODES = %i[
        if case while until for
        rescue when and or
      ].freeze

      def initialize(ast)
        @ast = ast
        @complexity = 1 # Start at 1 for the base path
      end

      def calculate
        # Lazy load the parser gem only when we need to process AST nodes to avoid introducing unnecessary
        # dependencies for use cases that do not exercise this functionality.
        require 'parser/current'

        process(@ast)
        @complexity
      end

      private

      def process(node)
        return unless node.is_a?(Parser::AST::Node)

        # Increment complexity for each branching node
        @complexity += 1 if COMPLEXITY_NODES.include?(node.type)

        # Process children
        node.children.each do |child|
          # Nodes can have children that are Symbols, Integers, Strings, or nil
          # We only want to process actual AST nodes
          process(child) if child.is_a?(Parser::AST::Node)
        end
      end
    end
  end
end
