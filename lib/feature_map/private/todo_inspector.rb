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

        # NOTE: This does not currently support detecting Python-style mult-line TODO comments
        # because the ending comment declaration is the same as the start. So, we'd have to
        # rewrite this to match againt the whole file instead of individual lines.
        in_comment = false
        content.each_line.with_index do |line, index|
          in_comment ||= line.match?(ENTERING_COMMENT)

          if in_comment && (match = line.match(TODO_PATTERN))
            todos["#{@file_path}:#{index + 1}"] = match[:content].strip
          end

          in_comment &&= !line.match?(EXITING_COMMENT)
        end

        [todos.length, todos]
      end
    end
  end
end
