# typed: true

module FeatureMap
  module Private
    module FeaturePlugins
      class Assignment < FeatureMap::CodeFeatures::Plugin
        extend T::Sig
        extend T::Helpers

        sig { returns(T::Array[String]) }
        def assigned_globs
          @feature.raw_hash['assigned_globs'] || []
        end
      end
    end
  end
end
