# @feature Code Features
module FeatureMap
  module Private
    module FeaturePlugins
      class Assignment < FeatureMap::CodeFeatures::Plugin
        def assigned_globs
          @feature.raw_hash['assigned_globs'] || []
        end
      end
    end
  end
end
