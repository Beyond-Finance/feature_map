# frozen_string_literal: true

# typed: strict

module FeatureMap
  module Constants
    SINGLE_LINE_COMMENT_PATTERNS = T.let(['#', '//'].map { |r| Regexp.escape(r) }.freeze, T::Array[String])
    MULTILINE_COMMENT_START_PATTERNS = T.let(['/*', '<!--', '"""', "'''"].map { |r| Regexp.escape(r) }.freeze, T::Array[String])
    MULTILINE_COMMENT_END_PATTERNS = T.let(['*/', '-->', '"""', "'''"].map { |r| Regexp.escape(r) }.freeze, T::Array[String])
    ALL_COMMENT_START_PATTERNS = T.let(SINGLE_LINE_COMMENT_PATTERNS + MULTILINE_COMMENT_START_PATTERNS, T::Array[String])
  end
end
