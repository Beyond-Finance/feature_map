# @feature Metrics Calculation
# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::PercentileMetricsCalculator do
    let(:metrics) do
      {
        'Foo' => {
          'abc_size' => 500.08,
          'cyclomatic_complexity' => 74,
          'lines_of_code' => 449,
          'todo_locations' => {
            'app/models/foo:12' => 'Fix Me',
            'app/services/foo:145' => 'Refactor'
          },
          'complexity_ratio' => 6.0675675675675675,
          'encapsulation_ratio' => 0.015590200445434299
        },
        'Bar' => {
          'abc_size' => 300.15,
          'cyclomatic_complexity' => 45,
          'lines_of_code' => 320,
          'todo_locations' => {
            'spec/models/bar:45' => 'Add assertion'
          },
          'complexity_ratio' => 4.5,
          'encapsulation_ratio' => 0.025
        },
        'Baz' => {
          'abc_size' => 200.22,
          'cyclomatic_complexity' => 30,
          'lines_of_code' => 150,
          'todo_locations' => {},
          'complexity_ratio' => 3.0,
          'encapsulation_ratio' => 0.05
        }
      }
    end

    let(:test_coverage) do
      {
        'Foo' => {
          'coverage_ratio' => 90
        },
        'Bar' => {
          'coverage_ratio' => 75
        },
        'Baz' => {
          'coverage_ratio' => 95
        }
      }
    end

    subject { described_class.new(metrics: metrics, test_coverage: test_coverage) }

    describe '#cyclomatic_complexity_for' do
      it 'calculates the correct percentile for an existing feature' do
        result = subject.cyclomatic_complexity_for('Foo')
        # For 6.0675... in [6.0675..., 4.5, 3.0], we have:
        # 2 values below (4.5, 3.0) and 0.5 for the exact match → 2.5 below or equal
        # (100 * 2.5) / 3 = 83.33 percentile
        expect(result['percentile']).to be_within(0.1).of(83.3)
        expect(result['percent_of_max']).to eq(100)
        expect(result['score']).to eq(6.0675675675675675)
      end

      it 'calculates the correct percentile for a feature with mid-range value' do
        result = subject.cyclomatic_complexity_for('Bar')
        # For 4.5 in [6.0675..., 4.5, 3.0], we have:
        # 1 value below (3.0) and 0.5 for the exact match → 1.5 below or equal
        # (100 * 1.5) / 3 = 50 percentile
        expect(result['percentile']).to be_within(0.1).of(50.0)
        expect(result['percent_of_max']).to eq(74) # 4.5/6.0675... ≈ 74%
        expect(result['score']).to eq(4.5)
      end

      it 'calculates the correct percentile for the lowest value feature' do
        result = subject.cyclomatic_complexity_for('Baz')
        # For 3.0 in [6.0675..., 4.5, 3.0], we have:
        # 0 values below and 0.5 for the exact match → 0.5 below or equal
        # (100 * 0.5) / 3 = 16.67 percentile
        expect(result['percentile']).to be_within(0.1).of(16.7)
        expect(result['percent_of_max']).to eq(49) # 3.0/6.0675... ≈ 49%
        expect(result['score']).to eq(3.0)
      end

      it 'returns zero values for a non-existent feature' do
        result = subject.cyclomatic_complexity_for('NonExistent')
        expect(result['percentile']).to eq(0.0)
        expect(result['percent_of_max']).to eq(0)
        expect(result['score']).to eq(0)
      end

      context 'with empty metrics collection' do
        let(:metrics) { {} }

        it 'returns zero values when no metrics exist' do
          result = subject.cyclomatic_complexity_for('Foo')
          expect(result['percentile']).to eq(0.0)
          expect(result['percent_of_max']).to eq(0)
          expect(result['score']).to eq(0)
        end
      end

      context 'with all zero values' do
        let(:metrics) do
          {
            'Foo' => { 'complexity_ratio' => 0 },
            'Bar' => { 'complexity_ratio' => 0 }
          }
        end

        it 'handles all zero values gracefully' do
          result = subject.cyclomatic_complexity_for('Foo')
          # When all values are 0, including the target, the percentile is 50%
          # because none are below, but all are equal (counting as 0.5 each)
          expect(result['percentile']).to eq(50.0)
          expect(result['percent_of_max']).to eq(0)
          expect(result['score']).to eq(0)
        end
      end

      context 'with repeated values' do
        let(:metrics) do
          {
            'Foo' => { 'complexity_ratio' => 5.0 },
            'Bar' => { 'complexity_ratio' => 5.0 },
            'Baz' => { 'complexity_ratio' => 5.0 }
          }
        end

        it 'calculates percentiles correctly for repeated values' do
          result = subject.cyclomatic_complexity_for('Foo')
          # For 5.0 in [5.0, 5.0, 5.0], all values are equal
          # 0 values below and 3 * 0.5 for exact matches → 1.5 below or equal
          # (100 * 1.5) / 3 = 50 percentile
          expect(result['percentile']).to be_within(0.1).of(50.0)
          expect(result['percent_of_max']).to eq(100)
          expect(result['score']).to eq(5.0)
        end
      end
    end

    describe '#encapsulation_for' do
      it 'calculates the correct percentile for an existing feature' do
        result = subject.encapsulation_for('Foo')
        # For 0.01559... in [0.01559..., 0.025, 0.05], we have:
        # 0 values below and 0.5 for the exact match → 0.5 below or equal
        # (100 * 0.5) / 3 = 16.67 percentile
        expect(result['percentile']).to be_within(0.1).of(16.7)
        # 0.01559/0.05 ≈ 0.3118 → 31%
        expect(result['percent_of_max']).to eq(31)
        expect(result['score']).to eq(0.015590200445434299)
      end

      it 'calculates the correct percentile for a feature with mid-range value' do
        result = subject.encapsulation_for('Bar')
        # For 0.025 in [0.01559..., 0.025, 0.05], we have:
        # 1 value below (0.01559...) and 0.5 for the exact match → 1.5 below or equal
        # (100 * 1.5) / 3 = 50 percentile
        expect(result['percentile']).to be_within(0.1).of(50.0)
        expect(result['percent_of_max']).to eq(50) # 0.025/0.05 = 50%
        expect(result['score']).to eq(0.025)
      end

      it 'calculates the correct percentile for the highest value feature' do
        result = subject.encapsulation_for('Baz')
        # For 0.05 in [0.01559..., 0.025, 0.05], we have:
        # 2 values below (0.01559..., 0.025) and 0.5 for the exact match → 2.5 below or equal
        # (100 * 2.5) / 3 = 83.33 percentile
        expect(result['percentile']).to be_within(0.1).of(83.3)
        expect(result['percent_of_max']).to eq(100) # 0.05/0.05 = 100%
        expect(result['score']).to eq(0.05)
      end

      it 'returns zero values for a non-existent feature' do
        result = subject.encapsulation_for('NonExistent')
        expect(result['percentile']).to eq(0.0)
        expect(result['percent_of_max']).to eq(0)
        expect(result['score']).to eq(0)
      end
    end

    describe '#feature_size_for' do
      it 'calculates the correct percentile for an existing feature' do
        result = subject.feature_size_for('Foo')
        # For 449 in [449, 320, 150], we have:
        # 2 values below (320, 150) and 0.5 for the exact match → 2.5 below or equal
        # (100 * 2.5) / 3 = 83.33 percentile
        expect(result['percentile']).to be_within(0.1).of(83.3)
        expect(result['percent_of_max']).to eq(100)
        expect(result['score']).to eq(449)
      end

      it 'calculates the correct percentile for a feature with mid-range value' do
        result = subject.feature_size_for('Bar')
        # For 320 in [449, 320, 150], we have:
        # 1 value below (150) and 0.5 for the exact match → 1.5 below or equal
        # (100 * 1.5) / 3 = 50 percentile
        expect(result['percentile']).to be_within(0.1).of(50.0)
        expect(result['percent_of_max']).to eq(71) # 320/449 ≈ 71%
        expect(result['score']).to eq(320)
      end

      it 'calculates the correct percentile for the lowest value feature' do
        result = subject.feature_size_for('Baz')
        # For 150 in [449, 320, 150], we have:
        # 0 values below and 0.5 for the exact match → 0.5 below or equal
        # (100 * 0.5) / 3 = 16.67 percentile
        expect(result['percentile']).to be_within(0.1).of(16.7)
        expect(result['percent_of_max']).to eq(33) # 150/449 ≈ 33%
        expect(result['score']).to eq(150)
      end

      it 'returns zero values for a non-existent feature' do
        result = subject.feature_size_for('NonExistent')
        expect(result['percentile']).to eq(0.0)
        expect(result['percent_of_max']).to eq(0)
        expect(result['score']).to eq(0)
      end
    end

    describe '#test_coverage_for' do
      it 'calculates the correct percentile for an existing feature' do
        result = subject.test_coverage_for('Foo')
        # For 90 in [90, 75, 95], we have:
        # 1 value below (75) and 0.5 for the exact match → 1.5 below or equal
        # (100 * 1.5) / 3 = 50.0 percentile
        expect(result['percentile']).to be_within(0.1).of(50.0)
        # 90/95 ≈ 0.947 → 95%
        expect(result['percent_of_max']).to eq(95)
        expect(result['score']).to eq(90)
      end

      it 'calculates the correct percentile for the lowest value feature' do
        result = subject.test_coverage_for('Bar')
        # For 75 in [90, 75, 95], we have:
        # 0 values below and 0.5 for the exact match → 0.5 below or equal
        # (100 * 0.5) / 3 = 16.67 percentile
        expect(result['percentile']).to be_within(0.1).of(16.7)
        expect(result['percent_of_max']).to eq(79) # 75/95 ≈ 79%
        expect(result['score']).to eq(75)
      end

      it 'calculates the correct percentile for the highest value feature' do
        result = subject.test_coverage_for('Baz')
        # For 95 in [90, 75, 95], we have:
        # 2 values below (90, 75) and 0.5 for the exact match → 2.5 below or equal
        # (100 * 2.5) / 3 = 83.33 percentile
        expect(result['percentile']).to be_within(0.1).of(83.3)
        expect(result['percent_of_max']).to eq(100)
        expect(result['score']).to eq(95)
      end

      it 'returns zero values for a non-existent feature' do
        result = subject.test_coverage_for('NonExistent')
        expect(result['percentile']).to eq(0.0)
        expect(result['percent_of_max']).to eq(0)
        expect(result['score']).to eq(0)
      end
    end

    describe '#todo_count_for' do
      it 'calculates the correct percentile for an existing feature' do
        result = subject.todo_count_for('Foo')
        expect(result['percentile']).to be_within(0.1).of(83.3)
        expect(result['percent_of_max']).to eq(100)
        expect(result['score']).to eq(2)
      end

      it 'calculates the correct percentile for a feature with mid-range value' do
        result = subject.todo_count_for('Bar')
        expect(result['percentile']).to be_within(0.1).of(50.0)
        expect(result['percent_of_max']).to eq(50)
        expect(result['score']).to eq(1)
      end

      it 'calculates the correct percentile for the lowest value feature' do
        result = subject.todo_count_for('Baz')
        expect(result['percentile']).to be_within(0.1).of(16.7)
        expect(result['percent_of_max']).to eq(0)
        expect(result['score']).to eq(0)
      end

      it 'returns zero values for a non-existent feature' do
        result = subject.todo_count_for('NonExistent')
        expect(result['percentile']).to eq(0.0)
        expect(result['percent_of_max']).to eq(0)
        expect(result['score']).to eq(0)
      end

      context 'with empty metrics collection' do
        let(:metrics) { {} }

        it 'returns zero values when no metrics exist' do
          result = subject.todo_count_for('Foo')
          expect(result['percentile']).to eq(0.0)
          expect(result['percent_of_max']).to eq(0)
          expect(result['score']).to eq(0)
        end
      end

      context 'with all zero values' do
        let(:metrics) do
          {
            'Foo' => { 'todo_locations' => {} },
            'Bar' => { 'todo_locations' => {} }
          }
        end

        it 'handles all zero values gracefully' do
          result = subject.todo_count_for('Foo')
          # When all values are 0, including the target, the percentile is 50%
          # because none are below, but all are equal (counting as 0.5 each)
          expect(result['percentile']).to eq(50.0)
          expect(result['percent_of_max']).to eq(0)
          expect(result['score']).to eq(0)
        end
      end

      context 'with repeated values' do
        let(:metrics) do
          {
            'Foo' => { 'todo_locations' => { 'somewhere:12' => 'make it slightly better' } },
            'Bar' => { 'todo_locations' => { 'somewhere:12' => 'make it slightly better' } },
            'Baz' => { 'todo_locations' => { 'somewhere:12' => 'make it slightly better' } }
          }
        end

        it 'calculates percentiles correctly for repeated values' do
          result = subject.todo_count_for('Foo')
          # For 5.0 in [5.0, 5.0, 5.0], all values are equal
          # 0 values below and 3 * 0.5 for exact matches → 1.5 below or equal
          # (100 * 1.5) / 3 = 50 percentile
          expect(result['percentile']).to be_within(0.1).of(50.0)
          expect(result['percent_of_max']).to eq(100)
          expect(result['score']).to eq(1)
        end
      end
    end

    context 'with different edge cases' do
      context 'with single item collections' do
        let(:metrics) do
          { 'Foo' => { 'complexity_ratio' => 5.0, 'encapsulation_ratio' => 0.02, 'lines_of_code' => 100 } }
        end

        let(:test_coverage) do
          { 'Foo' => { 'coverage_ratio' => 80 } }
        end

        it 'calculates percentiles correctly for single value' do
          # For a collection with only one value, the percentile will be 50%
          # as it's counted as 0.5 / 1 * 100
          result = subject.cyclomatic_complexity_for('Foo')
          expect(result['percentile']).to be_within(0.1).of(50.0)
          expect(result['percent_of_max']).to eq(100)
          expect(result['score']).to eq(5.0)
        end
      end

      context 'with empty collections' do
        let(:metrics) { {} }
        let(:test_coverage) { {} }

        it 'handles empty collections gracefully' do
          expect(subject.cyclomatic_complexity_for('Foo')['percentile']).to eq(0.0)
          expect(subject.encapsulation_for('Foo')['percentile']).to eq(0.0)
          expect(subject.feature_size_for('Foo')['percentile']).to eq(0.0)
          expect(subject.test_coverage_for('Foo')['percentile']).to eq(0.0)
        end
      end

      context 'with nil values in metrics' do
        let(:metrics) do
          {
            'Foo' => { 'complexity_ratio' => nil, 'encapsulation_ratio' => 0.02, 'lines_of_code' => 100 },
            'Bar' => { 'complexity_ratio' => 5.0, 'encapsulation_ratio' => 0.03, 'lines_of_code' => 200 }
          }
        end

        it 'excludes nil values from percentile calculations' do
          # With nil excluded, Bar's complexity_ratio of 5.0 should be at 50 percentile
          # as the only value in the collection
          result = subject.cyclomatic_complexity_for('Bar')
          expect(result['percentile']).to be_within(0.1).of(50.0)
          expect(result['score']).to eq(5.0)
        end

        it 'returns zero score for feature with nil value' do
          result = subject.cyclomatic_complexity_for('Foo')
          expect(result['percentile']).to eq(0.0)
          expect(result['score']).to eq(0)
        end
      end
    end
  end
end
