# @feature Core Library
# frozen_string_literal: true

module FeatureMap
  module Constants
    SINGLE_LINE_COMMENT_PATTERNS = ['#', '//'].map { |r| Regexp.escape(r) }.freeze
    MULTILINE_COMMENT_START_PATTERNS = ['/*', '<!--', '"""', "'''"].map { |r| Regexp.escape(r) }.freeze
    MULTILINE_COMMENT_END_PATTERNS = ['*/', '-->', '"""', "'''"].map { |r| Regexp.escape(r) }.freeze
  end
end
