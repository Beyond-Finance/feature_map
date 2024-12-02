# typed: false
# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::CyclomaticComplexityCalculator do
    describe '#calculate' do
      it 'returns 1 for an empty method' do
        code = 'def empty_method; end'
        source = RuboCop::ProcessedSource.new(code, RUBY_VERSION.to_f)
        calculator = described_class.new(source.ast)

        expect(calculator.calculate).to eq(1)
      end

      it 'counts if statements' do
        code = <<~RUBY
          def complex_method
            if condition1
              do_something
            elsif condition2
              do_something_else
            end
          end
        RUBY

        source = RuboCop::ProcessedSource.new(code, RUBY_VERSION.to_f)
        calculator = described_class.new(source.ast)

        expect(calculator.calculate).to eq(3) # Base 1 + 2 conditions
      end

      it 'counts logical operators' do
        code = <<~RUBY
          def complex_method
            if condition1 && condition2 || condition3
              do_something
            end
          end
        RUBY

        source = RuboCop::ProcessedSource.new(code, RUBY_VERSION.to_f)
        calculator = described_class.new(source.ast)

        expect(calculator.calculate).to eq(4) # Base 1 + if + and + or
      end
    end
  end
end
