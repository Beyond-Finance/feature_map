module FeatureMap
  module Validator
    def validation_errors(files:, autocorrect: true, stage_changes: true); end

    class << self
      def included(base)
        @validators ||= []
        @validators << base
      end

      def all
        (@validators || []).map(&:new)
      end
    end
  end
end
