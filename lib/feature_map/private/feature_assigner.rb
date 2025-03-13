# @feature Feature Assignment
# frozen_string_literal: true

module FeatureMap
  module Private
    class FeatureAssigner
      def self.assign_features(globs_to_assigned_feature_map)
        globs_to_assigned_feature_map.each_with_object({}) do |(glob, feature), mapping|
          # addresses the case where a directory name includes regex characters
          # such as `app/services/[test]/some_other_file.ts`
          mapping[glob] = feature if File.exist?(glob)
          Dir.glob(glob).each do |file|
            mapping[file] ||= feature
          end
        end
      end
    end
  end
end
