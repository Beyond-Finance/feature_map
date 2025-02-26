# frozen_string_literal: true

module FeatureMap
  module Private
    class TodoInspector
      ENTERING_COMMENT = /
        (#{(Constants::SINGLE_LINE_COMMENT_PATTERNS + Constants::MULTILINE_COMMENT_START_PATTERNS).join('|')})
      /x.freeze

      EXITING_COMMENT = /
        (#{(Constants::SINGLE_LINE_COMMENT_PATTERNS + Constants::MULTILINE_COMMENT_END_PATTERNS).join('|')})
      /x.freeze

      TODO_PATTERN = /
        TODO:?\s* # TODO with optional colon with whitespace
        (?<content>.*?) # The actual TODO content
        (#{Constants::MULTILINE_COMMENT_END_PATTERNS.join('|')})?$ # ignores comment end patterns
      /xi.freeze

      def initialize(file_path)
        @file_path = file_path
      end

      def calculate
        todos = {}
        content = File.read(@file_path)
        in_comment = false

        content.each_line.with_index do |line, index|
          in_comment ||= line.match?(ENTERING_COMMENT)

          if in_comment && (match = line.match(TODO_PATTERN))
            todos["#{@file_path}:#{index + 1}"] = match[:content].strip
          end

          in_comment &&= !line.match?(EXITING_COMMENT)
        end

        todos
      end
    end
  end
end
