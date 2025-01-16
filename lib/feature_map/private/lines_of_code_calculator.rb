# typed: strict
# frozen_string_literal: true

require 'parser/current'

module FeatureMap
  module Private
    class LinesOfCodeCalculator
      extend T::Sig

      # NOTE:  regex 'x' arg ignores whitespace within the _construction_ of the regex.
      #        regex 'm' arg allows the regex to _execute_ on multiline strings.
      SINGLE_LINE_COMMENT_PATTERN = T.let(
        /
          \s* # Any amount of whitespace
          (#{Constants::SINGLE_LINE_COMMENT_PATTERNS.join('|')}) # Any comment start
          .* # And the rest of the line
        /x.freeze,
        Regexp
      )
      MULTI_LINE_COMMENT_PATTERN = T.let(
        /
          (#{Constants::MULTILINE_COMMENT_START_PATTERNS.join('|')}) # Multiline comment start
          .*? # Everything in between, but lazily so we stop when we hit...
          (#{Constants::MULTILINE_COMMENT_END_PATTERNS.join('|')}) # ...Multiline comment end
        /xm.freeze,
        Regexp
      )

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
