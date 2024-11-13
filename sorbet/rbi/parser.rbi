# typed: true

module Parser
  class AST
    class Node
      sig { returns(Symbol) }
      def type; end

      sig { returns(T::Array[T.untyped]) }
      def children; end

      sig { params(other: BasicObject).returns(T::Boolean) }
      def ==(other); end
    end
  end
end
