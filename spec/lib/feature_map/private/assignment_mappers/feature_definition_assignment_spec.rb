module FeatureMap
  RSpec.describe Private::AssignmentMappers::FeatureDefinitionAssignment do
    before do
      write_configuration('assigned_globs' => '**/*')
      write_file('.feature_map/feature_definitions.csv', <<~CSV.strip)
        Name,Description,Documentation Link,Dashboard Link,Custom Attribute
        Bar,,,,
      CSV
      write_file('foo.rb', <<~FILE.strip)
        # @feature Bar
      FILE
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

          ## Feature definition file assignment
          - .feature_map/definitions/bar.yml
        FEATURE_REPORT
      end

      context 'when feature definition files are configured to be ignored' do
        before { write_configuration('ignore_feature_definitions' => true) }

        it 'does not include any files for this mapper' do
          expect(FeatureMap.for_feature('Bar')).to eq <<~FEATURE_REPORT
            # Report for `Bar` Feature
            ## Annotations at the top of file
            This feature does not have any files in this category.

            ## Feature-specific assigned globs
            This feature does not have any files in this category.

            ## Feature Assigned in .feature
            This feature does not have any files in this category.

            ## Feature definition file assignment
            This feature does not have any files in this category.
          FEATURE_REPORT
        end
      end
    end

    describe 'FeatureMap.for_file' do
      it 'maps a feature definition file to the feature itself' do
        expect(FeatureMap.for_file('.feature_map/definitions/bar.yml').name).to eq 'Bar'
      end

      context 'when feature definition files are configured to be ignored' do
        before { write_configuration('ignore_feature_definitions' => true) }

        it 'returns nil for feature definition files' do
          expect(FeatureMap.for_file('.feature_map/definitions/bar.yml')).to be_nil
        end
      end
    end
  end
end
