# typed: false
# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::LinesOfCodeCalculator do
    let(:calculator) { described_class.new(file_path) }
    let(:file_path) { 'app/lines_of_code_test.rb' }

    describe '#calculate' do
      it 'returns 0 for a file with only comments and whitespace' do
        # rubocop:disable Layout/TrailingWhitespace
        write_file(file_path, <<~CONTENTS)
          # Test 123
            
          \t 
            
        CONTENTS
        # rubocop:enable Layout/TrailingWhitespace

        expect(calculator.calculate).to eq(0)
      end

      it 'includes module, class, and method defitions in the count' do
        write_file(file_path, <<~CONTENTS)
          module FeatureMap
            class LinesOfCodeTest
              def self.a_method; end
            end
          end
        CONTENTS

        expect(calculator.calculate).to eq(5)
      end

      it 'includes constants and each line of array/hash defitions in the count' do
        write_file(file_path, <<~CONTENTS)
          class LinesOfCodeTest
            SOME_CONSTANT_ARRAY = [
              1,
              2,
              3
            ].freeze

            ANOTHER_CONSTANT_HASH = {
              a: 1,
              b: 2,
              c: 3
            }.freeze
          end
        CONTENTS

        expect(calculator.calculate).to eq(12)
      end

      it 'includes all other source code lines in the count' do
        write_file(file_path, <<~CONTENTS)
          class LinesOfCodeTest
            attr_reader :number

            def initialize(number)
              @number = number
            end

            def add_one
              increment(1)
            end

            def subtract_two
              increment(-2)
            end

            def multiply_by_three
              multiply(3)
            end

            private

            def increment(count)
              @number += count
            end

            def multiply(multiple)
              @number *= multiple
            end
          end
        CONTENTS

        expect(calculator.calculate).to eq(22)
      end
    end
  end
end
