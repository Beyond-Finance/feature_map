# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::HealthCalculator do
    let(:metrics) do
      {
        'Foo' => {
          'abc_size' => 500.08,
          'cyclomatic_complexity' => 74,
          'lines_of_code' => 449,
          'todo_locations' => {},
          'complexity_ratio' => 6.0675675675675675,
          'encapsulation_ratio' => 0.015590200445434299
        },
        'Bar' => {
          'abc_size' => 300.15,
          'cyclomatic_complexity' => 45,
          'lines_of_code' => 320,
          'todo_locations' => {},
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

    let(:health_config) do
      {
        'components' => {
          'cyclomatic_complexity' => { 'weight' => 15, 'score_threshold' => 100, 'minimum_variance' => 10 },
          'encapsulation' => { 'weight' => 15, 'score_threshold' => 100, 'minimum_variance' => 10 },
          'test_coverage' => { 'weight' => 70, 'score_threshold' => 95 }
        }
      }
    end

    let(:percentile_metrics) do
      Private::PercentileMetricsCalculator.new(metrics: metrics, test_coverage: test_coverage)
    end

    subject { described_class.new(percentile_metrics: percentile_metrics, health_config: health_config) }

    describe '#health_score_for' do
      context 'with feature Foo' do
        let(:result) { subject.health_score_for('Foo') }

        it 'calculates the overall health score correctly' do
          # Test coverage: 90/95 * 70 = 66.32
          # Cyclomatic complexity: 15 (full points because percent_of_max is 100, above the 90 threshold)
          # Encapsulation: 15 * (16.7/100) = 2.505 (below threshold)
          expected_overall = 66.32 + 15 + 2.505
          expect(result['overall']).to be_within(0.1).of(expected_overall)
        end

        it 'calculates the test coverage component correctly' do
          component = result['test_coverage_component']
          expect(component['awardable_points']).to eq(70)
          expect(component['health_score']).to be_within(0.1).of(66.32)
          expect(component['exceeds_score_threshold']).to be false
        end

        it 'calculates the cyclomatic complexity component correctly' do
          component = result['cyclomatic_complexity_component']
          expect(component['awardable_points']).to eq(15)
          expect(component['health_score']).to eq(15)
          expect(component['close_to_maximum_score']).to be true
        end

        it 'calculates the encapsulation component correctly' do
          component = result['encapsulation_component']
          expect(component['awardable_points']).to eq(15)
          expect(component['health_score']).to be_within(0.1).of(2.505)
          expect(component['exceeds_score_threshold']).to be false
          expect(component['close_to_maximum_score']).to be false
        end
      end

      context 'with a feature that meets all thresholds' do
        before do
          # Create a feature with high percentiles and scores
          allow(percentile_metrics).to receive(:test_coverage_for).with('HighScores').and_return({
                                                                                                   'percentile' => 90.0,
                                                                                                   'percent_of_max' => 100,
                                                                                                   'score' => 98 # Above 95 threshold
                                                                                                 })

          allow(percentile_metrics).to receive(:cyclomatic_complexity_for).with('HighScores').and_return({
                                                                                                           'percentile' => 100.0, # Above threshold
                                                                                                           'percent_of_max' => 80, # Below percent_of_max_threshold
                                                                                                           'score' => 6.0
                                                                                                         })

          allow(percentile_metrics).to receive(:encapsulation_for).with('HighScores').and_return({
                                                                                                   'percentile' => 100.0, # Above threshold
                                                                                                   'percent_of_max' => 80, # Below percent_of_max_threshold
                                                                                                   'score' => 0.05
                                                                                                 })
        end

        it 'awards full points for all components' do
          result = subject.health_score_for('HighScores')

          # All components should get full points
          expect(result['test_coverage_component']['health_score']).to eq(70)
          expect(result['cyclomatic_complexity_component']['health_score']).to eq(15)
          expect(result['encapsulation_component']['health_score']).to eq(15)
          expect(result['overall']).to eq(100)
        end
      end

      context 'with a feature that is close to maximum but below threshold' do
        before do
          allow(percentile_metrics).to receive(:cyclomatic_complexity_for).with('CloseToMax').and_return({
                                                                                                           'percentile' => 80.0, # Below 100 threshold
                                                                                                           'percent_of_max' => 95, # Above 90 percent_of_max_threshold
                                                                                                           'score' => 5.0
                                                                                                         })

          allow(percentile_metrics).to receive(:encapsulation_for).with('CloseToMax').and_return({
                                                                                                   'percentile' => 80.0, # Below 100 threshold
                                                                                                   'percent_of_max' => 95, # Above 90 percent_of_max_threshold
                                                                                                   'score' => 0.04
                                                                                                 })

          allow(percentile_metrics).to receive(:test_coverage_for).with('CloseToMax').and_return({
                                                                                                   'percentile' => 80.0,
                                                                                                   'percent_of_max' => 95,
                                                                                                   'score' => 90 # Below 95 threshold
                                                                                                 })
        end

        it 'awards full points based on close_to_maximum_score for complexity and encapsulation' do
          result = subject.health_score_for('CloseToMax')

          # Complexity and encapsulation get full points due to close_to_maximum_score
          expect(result['cyclomatic_complexity_component']['health_score']).to eq(15)
          expect(result['cyclomatic_complexity_component']['close_to_maximum_score']).to be true

          expect(result['encapsulation_component']['health_score']).to eq(15)
          expect(result['encapsulation_component']['close_to_maximum_score']).to be true

          # Test coverage is below threshold and gets partial points
          expect(result['test_coverage_component']['health_score']).to be_within(0.1).of(66.32)

          # Overall is the sum
          expect(result['overall']).to be_within(0.1).of(66.32 + 15 + 15)
        end
      end

      context 'with feature Baz (meets test coverage threshold)' do
        let(:result) { subject.health_score_for('Baz') }

        it 'awards full points for test coverage above threshold' do
          component = result['test_coverage_component']
          expect(component['awardable_points']).to eq(70)
          expect(component['health_score']).to eq(70)
          expect(component['exceeds_score_threshold']).to be true
        end

        it 'calculates complexity and encapsulation components correctly' do
          # Complexity calculation for Baz:
          # - Percentile of 3.0 is 16.7% (it's the lowest value)
          # - 16.7/100 * 15 = 2.5 points
          expect(result['cyclomatic_complexity_component']['health_score']).to be_within(0.1).of(2.5)

          # Encapsulation calculation for Baz:
          # - Baz has the highest encapsulation_ratio (0.05), gets full points
          expect(result['encapsulation_component']['health_score']).to eq(15)
        end
      end

      context 'with non-existent feature' do
        let(:result) { subject.health_score_for('NonExistent') }

        it 'calculates all components with zero scores' do
          expect(result['test_coverage_component']['health_score']).to eq(0)
          expect(result['cyclomatic_complexity_component']['health_score']).to eq(0)
          expect(result['encapsulation_component']['health_score']).to eq(0)
          expect(result['overall']).to eq(0)
        end
      end

      context 'with config weights that add up to 100' do
        let(:health_config) do
          {
            'components' => {
              'cyclomatic_complexity' => { 'weight' => 30, 'score_threshold' => 80, 'minimum_variance' => 20 },
              'encapsulation' => { 'weight' => 30, 'score_threshold' => 80, 'minimum_variance' => 20 },
              'test_coverage' => { 'weight' => 40, 'score_threshold' => 90 }
            }
          }
        end

        it 'respects the configured weights and thresholds' do
          result = subject.health_score_for('Foo')

          # Test coverage: 90/90 * 40 = 40
          # Cyclomatic complexity: 30 (full points because percent_of_max is 100, above the 80 threshold)
          # Encapsulation: 30 * (16.7/80) = 6.26
          expected_overall = 40 + 30 + 6.26
          expect(result['overall']).to be_within(0.1).of(expected_overall)
        end
      end
    end
  end
end
