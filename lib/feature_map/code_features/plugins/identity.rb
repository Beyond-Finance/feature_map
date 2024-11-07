# typed: true

module FeatureMap
  module CodeFeatures
    module Plugins
      class Identity < Plugin
        extend T::Sig
        extend T::Helpers

        IdentityStruct = Struct.new(:name)

        sig { returns(IdentityStruct) }
        def identity
          IdentityStruct.new(
            @feature.raw_hash['name']
          )
        end

        sig { override.params(features: T::Array[CodeFeatures::Feature]).returns(T::Array[String]) }
        def self.validation_errors(features)
          errors = T.let([], T::Array[String])

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
