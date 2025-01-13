# typed: strict
# frozen_string_literal: true

require 'parser/current'

module FeatureMap
  module Private
    class LinesOfCodeCalculator
      extend T::Sig

      COMMENT_PATTERNS = T.let(['#', '//'].map { |r| Regexp.escape(r) }.freeze, T::Array[String])
      MULTILINE_COMMENT_START_PATTERNS = T.let(['/*', '<!--', '"""', "'''"].map { |r| Regexp.escape(r) }.freeze, T::Array[String])
      MULTILINE_COMMENT_END_PATTERNS = T.let(['*/', '-->', '"""', "'''"].map { |r| Regexp.escape(r) }.freeze, T::Array[String])

      SINGLE_LINE_COMMENT_PATTERN = T.let(/\s*(#{COMMENT_PATTERNS.join('|')}).*/.freeze, Regexp)
      MULTI_LINE_COMMENT_PATTERN = T.let(/(#{MULTILINE_COMMENT_START_PATTERNS.join('|')}).*?(#{MULTILINE_COMMENT_END_PATTERNS.join('|')})/m.freeze, Regexp)

      sig { params(file_path: String).void }
      def initialize(file_path)
        @file_path = file_path
      end

      sig { returns(Integer) }
      def calculate
        # Ignore lines that are entirely whitespace or that are entirely a comment.
        File
          .readlines(@file_path)
          .join("\n")
          .gsub(SINGLE_LINE_COMMENT_PATTERN, '')
          .gsub(MULTI_LINE_COMMENT_PATTERN, '')
          .split("\n")
          .reject { |l| l.strip == '' }
          .size
      end
    end
  end
end
