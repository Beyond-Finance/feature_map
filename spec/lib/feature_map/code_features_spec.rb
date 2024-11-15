RSpec.describe FeatureMap::CodeFeatures do
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
