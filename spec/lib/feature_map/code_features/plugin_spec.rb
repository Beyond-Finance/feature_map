RSpec.describe FeatureMap::CodeFeatures::Plugin do
  def write_feature_yml(extra_data: false)
    write_file('.feature_map/definitions/my_feature.yml', <<~YML.strip)
      name: My Feature
      extra_data: #{extra_data}
    YML
  end

  before do
    FeatureMap::CodeFeatures.bust_caches!

    test_plugin_class = Class.new(described_class) do
      def extra_data
        @feature.raw_hash['extra_data']
      end
    end
    stub_const('TestPlugin', test_plugin_class)
  end

  describe '.bust_caches!' do
    it 'clears all plugins feature registries ensuring cached configs are purged' do
      write_feature_yml(extra_data: true)
      feature = FeatureMap::CodeFeatures.find('My Feature')
      expect(TestPlugin.for(feature).extra_data).to be(true)
      write_feature_yml(extra_data: false)
      FeatureMap::CodeFeatures.bust_caches!
      feature = FeatureMap::CodeFeatures.find('My Feature')
      expect(TestPlugin.for(feature).extra_data).to be(false)
    end
  end
end
