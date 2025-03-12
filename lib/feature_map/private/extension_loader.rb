# @feature Extension System
# frozen_string_literal: true

module FeatureMap
  module Private
    # This class handles loading extensions to feature_map using the `require` directive
    # in the `.feature_map/config.yml` configuration.
    module ExtensionLoader
      class << self
        def load(require_directive)
          # We want to transform the require directive to behave differently
          # if it's a specific local file being required versus a gem
          if require_directive.start_with?('.')
            require File.join(Pathname.pwd, require_directive)
          else
            require require_directive
          end
        end
      end
    end
  end
end
