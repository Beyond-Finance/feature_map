# typed: strict
# frozen_string_literal: true

require_relative '../constants'

module FeatureMap
  module Private
    class TodoInspector
      extend T::Sig

      ENTERING_COMMENT = T.let(
        /
          (#{(Constants::SINGLE_LINE_COMMENT_PATTERNS + Constants::MULTILINE_COMMENT_START_PATTERNS).join('|')})
        /x.freeze,
        Regexp
      )

      EXITING_COMMENT = T.let(
        /
          (#{(Constants::SINGLE_LINE_COMMENT_PATTERNS + Constants::MULTILINE_COMMENT_END_PATTERNS).join('|')})
        /x.freeze,
        Regexp
      )

      TODO_PATTERN = T.let(
        /
          TODO:?\s* # TODO with optional colon with whitespace
          (?<content>.*?) # The actual TODO content
          (#{Constants::MULTILINE_COMMENT_END_PATTERNS.join('|')})?$ # ignores comment end patterns
        /xi.freeze,
        Regexp
      )

      sig { params(file_path: String).void }
      def initialize(file_path)
        @file_path = file_path
      end

      sig { returns([Integer, T::Hash[String, String]]) }
      def calculate
        todos = {}
        content = File.read(@file_path)

        # Explicitly type in_comment as T::Boolean
        in_comment = T.let(false, T::Boolean)

        content.each_line.with_index do |line, index|
          # Create a new boolean instead of modifying
          in_comment ||= line.match?(ENTERING_COMMENT)

          if in_comment && (match = line.match(TODO_PATTERN))
            # Use T.must to handle potential nil
            todos["#{@file_path}:#{index + 1}"] = T.must(match[:content]).strip
          end

          in_comment &&= !line.match?(EXITING_COMMENT)
        end

        [todos.length, todos]
      end
    end
  end
end
