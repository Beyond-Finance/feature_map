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
          'todo_locations' => { '/path/to/file.rb:[10]' => 'TODO: Fix issue', '/path/to/file.rb:[20]' => 'TODO: Refactor' },
          'complexity_ratio' => 6.0675675675675675,
          'encapsulation_ratio' => 0.015590200445434299
        },
        'Bar' => {
          'abc_size' => 300.15,
          'cyclomatic_complexity' => 45,
          'lines_of_code' => 320,
          'todo_locations' => { '/path/to/file2.rb:[5]' => 'TODO: Implement feature' },
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
          'cyclomatic_complexity' => { 'weight' => 5, 'percent_of_max_threshold' => 90 },
          'encapsulation' => { 'weight' => 10, 'percent_of_max_threshold' => 90 },
          'test_coverage' => { 'weight' => 70, 'percent_of_max_threshold' => 95 },
          'todo_count' => { 'weight' => 15, 'percent_of_max_threshold' => 95 }
        }
      }
    end

    let(:percentile_metrics) do
      instance_double(
        'FeatureMap::Private::PercentileMetricsCalculator',
        cyclomatic_complexity_for: nil,
        encapsulation_for: nil,
        test_coverage_for: nil,
        todo_count_for: nil
      )
    end

    subject { described_class.new(percentile_metrics: percentile_metrics, health_config: health_config) }

    describe '#health_score_for' do
      context 'with standard feature metrics' do
        let(:feature_name) { 'TestFeature' }
        let(:result) { subject.health_score_for(feature_name) }

        context 'when all metrics are below threshold' do
          before do
            # Test coverage - score is the absolute coverage value (not percentile)
            # The score is used directly, not the percentile
            allow(percentile_metrics).to receive(:test_coverage_for).with(feature_name).and_return({
                                                                                                     'percentile' => 80, # Not used for calculation
                                                                                                     'percent_of_max' => 80, # Below 95 threshold
                                                                                                     'score' => 80 # This is the actual coverage percentage used
                                                                                                   })

            # Cyclomatic complexity - percentile is used for calculation
            # percent_of_max below threshold means we don't get full points
            allow(percentile_metrics).to receive(:cyclomatic_complexity_for).with(feature_name).and_return({
                                                                                                             'percentile' => 70, # This value is used to calculate points (70% of max points)
                                                                                                             'percent_of_max' => 80, # Below 90 threshold
                                                                                                             'score' => 50 # Not used for calculation
                                                                                                           })

            # Encapsulation - percentile is used for calculation
            # percent_of_max below threshold means we don't get full points
            allow(percentile_metrics).to receive(:encapsulation_for).with(feature_name).and_return({
                                                                                                     'percentile' => 60, # This value is used to calculate points (60% of max points)
                                                                                                     'percent_of_max' => 80, # Below 90 threshold
                                                                                                     'score' => 0.03 # Not used for calculation
                                                                                                   })

            # Todo count - inverse percentile is used for calculation
            # 100 - percentile = 30, meaning 30% of max points
            # percent_of_max below threshold means we don't get full points
            allow(percentile_metrics).to receive(:todo_count_for).with(feature_name).and_return({
                                                                                                  'percentile' => 70, # 70th percentile is bad for todo count (inverted: 100-70 = 30)
                                                                                                  'percent_of_max' => 80, # 80% of max todos (inverted: 100-80 = 20, below 95 threshold)
                                                                                                  'score' => 5 # Not used for calculation
                                                                                                })
          end

          it 'calculates test coverage component correctly' do
            # Test coverage formula:
            # score / 100 * weight = 80 / 100 * 70 = 56
            component = result['test_coverage_component']
            expect(component['awardable_points']).to eq(70)
            expect(component['close_to_maximum_score']).to be false
            expect(component['health_score']).to be_within(0.1).of(56)
          end

          it 'calculates cyclomatic complexity component correctly' do
            # Cyclomatic complexity formula:
            # percentile / 100 * weight = 70 / 100 * 5 = 3.5
            component = result['cyclomatic_complexity_component']
            expect(component['awardable_points']).to eq(5)
            expect(component['close_to_maximum_score']).to be false
            expect(component['health_score']).to be_within(0.1).of(3.5)
          end

          it 'calculates encapsulation component correctly' do
            # Encapsulation formula:
            # percentile / 100 * weight = 60 / 100 * 10 = 6
            component = result['encapsulation_component']
            expect(component['awardable_points']).to eq(10)
            expect(component['close_to_maximum_score']).to be false
            expect(component['health_score']).to be_within(0.1).of(6)
          end

          it 'calculates todo count component correctly' do
            # Todo count formula (inverse):
            # (100 - percentile) / 100 * weight = (100 - 70) / 100 * 15 = 4.5
            component = result['todo_count_component']
            expect(component['awardable_points']).to eq(15)
            expect(component['close_to_maximum_score']).to be false
            expect(component['health_score']).to be_within(0.1).of(4.5)
          end

          it 'calculates the overall health score correctly' do
            # Sum of all components divided by total weight * 100
            test_coverage = 56
            cyclomatic_complexity = 3.5
            encapsulation = 6
            todo_count = 4.5

            expected_overall = (test_coverage + cyclomatic_complexity + encapsulation + todo_count) / 100.0 * 100
            expect(result['overall']).to be_within(0.1).of(expected_overall)
          end
        end

        context 'when all metrics are above threshold' do
          before do
            # Test coverage - above 95 threshold
            allow(percentile_metrics).to receive(:test_coverage_for).with(feature_name).and_return({
                                                                                                     'percentile' => 80, # Not used when above threshold
                                                                                                     'percent_of_max' => 96, # Above 95 threshold
                                                                                                     'score' => 96 # This value causes it to be above threshold
                                                                                                   })

            # Cyclomatic complexity - above 90 threshold
            allow(percentile_metrics).to receive(:cyclomatic_complexity_for).with(feature_name).and_return({
                                                                                                             'percentile' => 70, # Not used when above threshold
                                                                                                             'percent_of_max' => 95, # Above 90 threshold
                                                                                                             'score' => 50 # Not used
                                                                                                           })

            # Encapsulation - above 90 threshold
            allow(percentile_metrics).to receive(:encapsulation_for).with(feature_name).and_return({
                                                                                                     'percentile' => 60, # Not used when above threshold
                                                                                                     'percent_of_max' => 95, # Above 90 threshold
                                                                                                     'score' => 0.03 # Not used
                                                                                                   })

            # Todo count - inverted, but still above threshold
            # For todo count, we need the inverse to be above threshold
            # If percent_of_max is 5%, then 100-5 = 95%, which is exactly at threshold
            # So we use 4% to be just above the threshold
            allow(percentile_metrics).to receive(:todo_count_for).with(feature_name).and_return({
                                                                                                  'percentile' => 30, # Not used when above threshold
                                                                                                  'percent_of_max' => 4, # 100-4 = 96, above 95 threshold
                                                                                                  'score' => 5 # Not used
                                                                                                })
          end

          it 'awards full points for test coverage' do
            component = result['test_coverage_component']
            expect(component['awardable_points']).to eq(70)
            expect(component['close_to_maximum_score']).to be true
            expect(component['health_score']).to eq(70)
          end

          it 'awards full points for cyclomatic complexity' do
            component = result['cyclomatic_complexity_component']
            expect(component['awardable_points']).to eq(5)
            expect(component['close_to_maximum_score']).to be true
            expect(component['health_score']).to eq(5)
          end

          it 'awards full points for encapsulation' do
            component = result['encapsulation_component']
            expect(component['awardable_points']).to eq(10)
            expect(component['close_to_maximum_score']).to be true
            expect(component['health_score']).to eq(10)
          end

          it 'awards full points for todo count' do
            component = result['todo_count_component']
            expect(component['awardable_points']).to eq(15)
            expect(component['close_to_maximum_score']).to be true
            expect(component['health_score']).to eq(15)
          end

          it 'awards maximum possible score' do
            # All components get full points
            expect(result['overall']).to eq(100)
          end
        end

        context 'when only some metrics are above threshold' do
          let(:feature_name) { 'MixedScores' }

          before do
            # Test coverage above threshold
            allow(percentile_metrics).to receive(:test_coverage_for).with(feature_name).and_return({
                                                                                                     'percentile' => 80, # Not used when above threshold
                                                                                                     'percent_of_max' => 96, # Above 95 threshold
                                                                                                     'score' => 96 # Actual coverage is 96%
                                                                                                   })

            # Cyclomatic complexity below threshold
            allow(percentile_metrics).to receive(:cyclomatic_complexity_for).with(feature_name).and_return({
                                                                                                             'percentile' => 70, # Used for calculation
                                                                                                             'percent_of_max' => 80, # Below 90 threshold
                                                                                                             'score' => 50 # Not used
                                                                                                           })

            # Encapsulation above threshold
            allow(percentile_metrics).to receive(:encapsulation_for).with(feature_name).and_return({
                                                                                                     'percentile' => 60, # Not used when above threshold
                                                                                                     'percent_of_max' => 95, # Above 90 threshold
                                                                                                     'score' => 0.03 # Not used
                                                                                                   })

            # Todo count below threshold
            allow(percentile_metrics).to receive(:todo_count_for).with(feature_name).and_return({
                                                                                                  'percentile' => 20, # Used for calculation (100-20 = 80% of points)
                                                                                                  'percent_of_max' => 20, # Below 95 threshold (100-20 = 80, below 95)
                                                                                                  'score' => 5 # Not used
                                                                                                })
          end

          it 'correctly calculates mixed threshold components' do
            # Test coverage gets full points due to being above threshold
            expect(result['test_coverage_component']['health_score']).to eq(70)
            expect(result['test_coverage_component']['close_to_maximum_score']).to be true

            # Cyclomatic complexity gets partial points
            expect(result['cyclomatic_complexity_component']['health_score']).to be_within(0.1).of(3.5) # 70% of 5
            expect(result['cyclomatic_complexity_component']['close_to_maximum_score']).to be false

            # Encapsulation gets full points due to being above threshold
            expect(result['encapsulation_component']['health_score']).to eq(10)
            expect(result['encapsulation_component']['close_to_maximum_score']).to be true

            # Todo count gets partial points (score is inverted, so 80% of points)
            expect(result['todo_count_component']['health_score']).to be_within(0.1).of(12) # (100-20)% of 15
            expect(result['todo_count_component']['close_to_maximum_score']).to be false
          end

          it 'calculates overall score as weighted sum' do
            test_coverage = 70 # Full points
            cyclomatic_complexity = 3.5 # 70% of 5
            encapsulation = 10 # Full points
            todo_count = 12 # 80% of 15

            expected_overall = (test_coverage + cyclomatic_complexity + encapsulation + todo_count) / 100.0 * 100
            expect(result['overall']).to be_within(0.1).of(expected_overall)
          end
        end
      end

      context 'with non-existent feature' do
        before do
          # Return zeros for all metrics when feature doesn't exist
          allow(percentile_metrics).to receive(:test_coverage_for).with('NonExistent').and_return({
                                                                                                    'percentile' => 0,
                                                                                                    'percent_of_max' => 0,
                                                                                                    'score' => 0
                                                                                                  })

          allow(percentile_metrics).to receive(:cyclomatic_complexity_for).with('NonExistent').and_return({
                                                                                                            'percentile' => 0,
                                                                                                            'percent_of_max' => 0,
                                                                                                            'score' => 0
                                                                                                          })

          allow(percentile_metrics).to receive(:encapsulation_for).with('NonExistent').and_return({
                                                                                                    'percentile' => 0,
                                                                                                    'percent_of_max' => 0,
                                                                                                    'score' => 0
                                                                                                  })

          allow(percentile_metrics).to receive(:todo_count_for).with('NonExistent').and_return({
                                                                                                 'percentile' => 100, # Worst possible percentile for todos
                                                                                                 'percent_of_max' => 100, # 100% of max (worst)
                                                                                                 'score' => 0 # Lowest possible score
                                                                                               })
        end

        let(:result) { subject.health_score_for('NonExistent') }

        it 'calculates all components with zero scores' do
          expect(result['test_coverage_component']['health_score']).to eq(0)
          expect(result['cyclomatic_complexity_component']['health_score']).to eq(0)
          expect(result['encapsulation_component']['health_score']).to eq(0)
          expect(result['todo_count_component']['health_score']).to eq(0)
          expect(result['overall']).to eq(0)
        end
      end
    end
  end
end
