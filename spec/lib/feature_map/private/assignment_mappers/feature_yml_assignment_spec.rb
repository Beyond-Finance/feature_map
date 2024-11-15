module FeatureMap
  RSpec.describe Private::AssignmentMappers::FeatureYmlAssignment do
    before do
      write_configuration
      write_file('.features/definitions/bar.yml', <<~CONTENTS)
        name: Bar
      CONTENTS
    end

    describe 'FeatureMap.for_feature' do
      it 'prints out assignment information for the given feature' do
        expect(FeatureMap.for_feature('Bar')).to eq <<~FEATURE_REPORT
          # Report for `Bar` Feature
          ## Annotations at the top of file
          This feature does not have any files in this category.

          ## Feature-specific assigned globs
          This feature does not have any files in this category.

          ## Feature Assigned in .feature
          This feature does not have any files in this category.

          ## Feature YML assignment
          - .features/definitions/bar.yml
        FEATURE_REPORT
      end
    end

    describe 'FeatureMap.for_file' do
      it 'maps a feature YML to be assigned to the feature itself' do
        expect(FeatureMap.for_file('.features/definitions/bar.yml').name).to eq 'Bar'
      end
    end
  end
end
