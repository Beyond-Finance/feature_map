# @feature Code Features
RSpec.describe FeatureMap::CodeFeatures do
  context 'when feature definitions are provided in YAML files' do
    let(:feature_yml) do
      <<~YML.strip
        name: My Feature
      YML
    end

    before do
      write_file('.feature_map/definitions/my_feature.yml', feature_yml)
      FeatureMap::CodeFeatures.bust_caches!
      allow(FeatureMap::CodeFeatures::Plugin).to receive(:registry).and_return({})
    end

    describe '.all' do
      it 'correctly parses the feature files' do
        expect(FeatureMap::CodeFeatures.all.count).to eq 1
        feature = FeatureMap::CodeFeatures.all.first
        expect(feature.name).to eq 'My Feature'
        expect(feature.raw_hash['name']).to eq 'My Feature'
        expect(feature.config_yml).to eq '.feature_map/definitions/my_feature.yml'
      end

      context 'feature YML has syntax errors' do
        let(:feature_yml) do
          <<~YML.strip
            name =>>>asdfaf!!@#!@#@!syntax error My Feature
            asdfsa: asdfs
          YML
        end

        it 'spits out a helpful error message' do
          expect { FeatureMap::CodeFeatures.all }.to raise_error do |e|
            expect(e).to be_a FeatureMap::CodeFeatures::IncorrectPublicApiUsageError
            expect(e.message).to eq('The YML in .feature_map/definitions/my_feature.yml has a syntax error!')
          end
        end
      end
    end

    describe 'validation_errors' do
      subject(:validation_errors) { FeatureMap::CodeFeatures.validation_errors(FeatureMap::CodeFeatures.all) }

      context 'there is one definition for all features' do
        it 'has no errors' do
          expect(validation_errors).to be_empty
        end
      end

      context 'there are multiple definitions for the same feature' do
        before do
          write_file('.feature_map/definitions/my_other_features.yml', feature_yml)
        end

        it 'registers the feature file as invalid' do
          expect(validation_errors).to match_array(
            [
              'More than 1 definition for My Feature found'
            ]
          )
        end
      end
    end

    describe '==' do
      it 'handles nil correctly' do
        expect(FeatureMap::CodeFeatures.all.first == nil).to eq false # rubocop:disable Style/NilComparison
        expect(FeatureMap::CodeFeatures.all.first.nil?).to eq false
      end
    end
  end

  context 'when feature definitions are provided in a CSV' do
    let(:features_csv) do
      <<~CSV.strip
        Name,Description,Documentation Link,Dashboard Link,Custom Attribute
        First Feature,A sample feature to test with.,https://www.notion.so/First-Feature-Docs-abc123,https://www.newrelic.com/firstFeatureDashboard,Test 123
        Second Feature,Yet another sample feature.,https://www.notion.so/Second-Feature-Docs-abc123,https://www.newrelic.com/secondFeatureDashboard,Test 456
        Third Feature
      CSV
    end

    before do
      write_file('.feature_map/feature_definitions.csv', features_csv)
      FeatureMap::CodeFeatures.bust_caches!
      allow(FeatureMap::CodeFeatures::Plugin).to receive(:registry).and_return({})
    end

    describe '.all' do
      it 'correctly parses all feature in the feature definitions csv file' do
        expect(FeatureMap::CodeFeatures.all.count).to eq 3
        first_feature = FeatureMap::CodeFeatures.all.first
        expect(first_feature.name).to eq 'First Feature'
        expect(first_feature.raw_hash['name']).to eq 'First Feature'
        expect(first_feature.raw_hash['description']).to eq 'A sample feature to test with.'
        expect(first_feature.raw_hash['documentation_link']).to eq 'https://www.notion.so/First-Feature-Docs-abc123'
        expect(first_feature.raw_hash['dashboard_link']).to eq 'https://www.newrelic.com/firstFeatureDashboard'
        expect(first_feature.raw_hash['custom_attribute']).to eq 'Test 123'
        expect(first_feature.config_yml).to be_nil

        second_feature = FeatureMap::CodeFeatures.all[1]
        expect(second_feature.name).to eq 'Second Feature'
        expect(second_feature.raw_hash['name']).to eq 'Second Feature'
        expect(second_feature.raw_hash['description']).to eq 'Yet another sample feature.'
        expect(second_feature.raw_hash['documentation_link']).to eq 'https://www.notion.so/Second-Feature-Docs-abc123'
        expect(second_feature.raw_hash['dashboard_link']).to eq 'https://www.newrelic.com/secondFeatureDashboard'
        expect(second_feature.raw_hash['custom_attribute']).to eq 'Test 456'
        expect(second_feature.config_yml).to be_nil

        third_feature = FeatureMap::CodeFeatures.all[2]
        expect(third_feature.name).to eq 'Third Feature'
        expect(third_feature.raw_hash['name']).to eq 'Third Feature'
        expect(third_feature.raw_hash['description']).to be_nil
        expect(third_feature.raw_hash['documentation_link']).to be_nil
        expect(third_feature.raw_hash['dashboard_link']).to be_nil
        expect(third_feature.raw_hash['custom_attribute']).to be_nil
        expect(third_feature.config_yml).to be_nil
      end

      context 'when the CSV file contains a Ruby-like comment' do
        let(:features_csv) do
          <<~CSV.strip
            # Comment explaining the purpose of this file and how it should be managed.

            Name,Description,Documentation Link,Dashboard Link,Custom Attribute
            First Feature,A sample feature to test with.,https://www.notion.so/First-Feature-Docs-abc123,https://www.newrelic.com/firstFeatureDashboard
          CSV
        end

        it 'ignores the comment entirely out a helpful error message' do
          expect(FeatureMap::CodeFeatures.all.count).to eq 1
          feature = FeatureMap::CodeFeatures.all.first
          expect(feature.name).to eq 'First Feature'
        end
      end

      context 'when the CSV file contains a Ruby-like comment' do
        let(:features_csv) do
          <<~CSV.strip
            # Comment explaining the purpose of this file and how it should be managed.

            Name,Description,Documentation Link,Dashboard Link,Custom Attribute
            First Feature,A sample feature to test with.,https://www.notion.so/First-Feature-Docs-abc123,https://www.newrelic.com/firstFeatureDashboard
          CSV
        end

        it 'ignores the comment entirely out a helpful error message' do
          expect(FeatureMap::CodeFeatures.all.count).to eq 1
          feature = FeatureMap::CodeFeatures.all.first
          expect(feature.name).to eq 'First Feature'
        end
      end

      context 'when the CSV file contains non-breaking space characters' do
        let(:non_breaking_space) { 65_279.chr(Encoding::UTF_8) }
        let(:features_csv) do
          <<~CSV.strip
            #{non_breaking_space}# Comment explaining the purpose of this file and how it should be managed.

            #{non_breaking_space}Name,Description,Documentation#{non_breaking_space} Link,Dashboard Link,Custom Attribute
            #{non_breaking_space}First Feature,A sample feature to test with.,https://www.notion.so/First-Feature-Docs-abc123,https://www.newrelic.com/firstFeatureDashboard
          CSV
        end

        it 'strips all non-breaking space characters from the CSV file' do
          expect(FeatureMap::CodeFeatures.all.count).to eq 1
          feature = FeatureMap::CodeFeatures.all.first
          expect(feature.name).to eq 'First Feature'
        end
      end
    end

    describe 'validation_errors' do
      subject(:validation_errors) { FeatureMap::CodeFeatures.validation_errors(FeatureMap::CodeFeatures.all) }

      context 'there is one definition for all features' do
        it 'has no errors' do
          expect(validation_errors).to be_empty
        end
      end

      context 'there are multiple definitions for the same feature' do
        let(:features_csv) do
          <<~CSV.strip
            Name,Description,Documentation Link,Dashboard Link,Custom Attribute
            First Feature,A sample feature to test with.,https://www.notion.so/First-Feature-Docs-abc123,https://www.newrelic.com/firstFeatureDashboard,Test 123
            Second Feature
            First Feature,Redefinition of the First feature.
          CSV
        end

        it 'registers the feature file as invalid' do
          expect(validation_errors).to match_array(
            [
              'More than 1 definition for First Feature found'
            ]
          )
        end
      end
    end
  end

  describe 'feature methods' do
    describe '#label' do
      let(:features_csv) do
        <<~CSV.strip
          Name,Description,Documentation Link,Dashboard Link,Custom Attribute
          A Feature,,,,
          A really long feature name I mean someone really went overboard here,,,,
        CSV
      end

      before do
        write_file('.feature_map/feature_definitions.csv', features_csv)
        FeatureMap::CodeFeatures.bust_caches!
        allow(FeatureMap::CodeFeatures::Plugin).to receive(:registry).and_return({})
      end

      it 'returns a feature label' do
        expect(FeatureMap::CodeFeatures.find('A Feature').label).to eq('Feature A Feature')
      end

      it 'truncates a long label' do
        long_feature = 'A really long feature name I mean someone really went overboard here'
        truncated_label = FeatureMap::CodeFeatures.find(long_feature).label
        expect(truncated_label).to eq('Feature A really long feature name I mean someone ')
        expect(truncated_label.size).to eq(FeatureMap::CodeFeatures::Feature::LABEL_LIMIT)
      end
    end
  end
end
