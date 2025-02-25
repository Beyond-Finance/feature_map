module FeatureMap
  module CodeFeatures
    module Plugins
      class Identity < Plugin
        IdentityStruct = Struct.new(:name)

        def identity
          IdentityStruct.new(
            @feature.raw_hash['name']
          )
        end

        def self.validation_errors(features)
          errors = []

          uniq_set = Set.new
          features.each do |feature|
            for_feature = self.for(feature)

            if !uniq_set.add?(for_feature.identity.name)
              errors << "More than 1 definition for #{for_feature.identity.name} found"
            end

            errors << missing_key_error_message(feature, 'name') if for_feature.identity.name.nil?
          end

          errors
        end
      end
    end
  end
end
