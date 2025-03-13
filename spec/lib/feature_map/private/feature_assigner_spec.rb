# @feature Feature Assignment
module FeatureMap
  RSpec.describe Private::FeatureAssigner do
    describe '.assign_features' do
      subject(:assign_features) { described_class.assign_features(globs_to_assigned_feature_map) }

      let(:feature1) { instance_double(CodeFeatures::Feature) }
      let(:feature2) { instance_double(CodeFeatures::Feature) }

      let(:globs_to_assigned_feature_map) do
        {
          'app/services/[test]/some_other_file.ts' => feature1,
          'app/services/withoutbracket/file.ts' => feature2,
          'app/models/*.rb' => feature2
        }
      end

      before do
        write_file('app/services/[test]/some_other_file.ts', <<~YML)
          // @feature Bar
        YML

        write_file('app/services/withoutbracket/file.ts', <<~YML)
          // @feature Bar
        YML
      end

      it 'returns a hash with the same keys and the values that are files' do
        expect(assign_features).to eq(
          'app/services/[test]/some_other_file.ts' => feature1,
          'app/services/withoutbracket/file.ts' => feature2
        )
      end

      context 'when file name includes square brackets' do
        let(:globs_to_assigned_feature_map) do
          {
            'app/services/[test]/some_other_[test]_file.ts' => feature1
          }
        end

        before do
          write_file('app/services/[test]/some_other_[test]_file.ts', <<~YML)
            // @feature Bar
          YML

          write_file('app/services/t/some_other_e_file.ts', <<~YML)
            // @feature Bar
          YML
        end

        it 'matches the glob pattern' do
          expect(assign_features).to eq(
            'app/services/[test]/some_other_[test]_file.ts' => feature1,
            'app/services/t/some_other_e_file.ts' => feature1
          )
        end
      end

      context 'when glob pattern also exists' do
        before do
          write_file('app/services/t/some_other_file.ts', <<~YML)
            // @feature Bar
          YML
        end

        it 'also matches the glob pattern' do
          expect(assign_features).to eq(
            'app/services/[test]/some_other_file.ts' => feature1,
            'app/services/t/some_other_file.ts' => feature1,
            'app/services/withoutbracket/file.ts' => feature2
          )
        end
      end

      context 'when * is used in glob pattern' do
        before do
          write_file('app/models/some_file.rb', <<~YML)
            // @feature Bar
          YML

          write_file('app/models/nested/some_file.rb', <<~YML)
            // @feature Bar
          YML
        end

        it 'also matches the glob pattern' do
          expect(assign_features).to eq(
            'app/services/[test]/some_other_file.ts' => feature1,
            'app/services/withoutbracket/file.ts' => feature2,
            'app/models/some_file.rb' => feature2
          )
        end
      end
    end
  end
end
