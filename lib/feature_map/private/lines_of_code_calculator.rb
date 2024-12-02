# typed: strict
# frozen_string_literal: true

require 'parser/current'

module FeatureMap
  module Private
    class LinesOfCodeCalculator
      extend T::Sig

      sig { params(file_path: String).void }
      def initialize(file_path)
        @file_path = file_path
      end

      sig { returns(Integer) }
      def calculate
        # Ignore lines that are entirely whitespace or that are entirely a comment.
        File.readlines(@file_path).grep_v(/\A\s*(#.*)?\Z/i).length
      end
    end
  end
end
