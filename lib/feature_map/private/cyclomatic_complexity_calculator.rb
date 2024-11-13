# typed: strict
# frozen_string_literal: true

require 'parser/current'
require 'sorbet-runtime'

module FeatureMap
  module Private
    class CyclomaticComplexityCalculator
      extend T::Sig

      COMPLEXITY_NODES = %i[
        if case while until for
        rescue when and or
      ].freeze

      sig { params(ast: T.nilable(Parser::AST::Node)).void }
      def initialize(ast)
        @ast = ast
        @complexity = T.let(1, Integer) # Start at 1 for the base path
      end

      sig { returns(Integer) }
      def calculate
        process(@ast)
        @complexity
      end

      private

      sig { params(node: T.nilable(T.any(Parser::AST::Node, Symbol, Integer, String, NilClass))).void }
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
