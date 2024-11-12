require 'spec_helper'
require 'tmpdir'

module FeatureMap
  RSpec.describe Private::ComplexityCalculator do
    describe '.calculate_for_file' do
      it 'calculates abc size for a simple file' do
        Dir.mktmpdir do |dir|
          file_path = File.join(dir, 'test.rb')
          content = <<~RUBY
            def simple_method
              x = 1
              y = 2
              x + y
            end
          RUBY

          File.write(file_path, content)

          metrics = described_class.calculate_for_file(file_path)
          expect(metrics['abc_size']).to be_kind_of(Numeric)
          expect(metrics['abc_size']).to be > 0
          expect(metrics['lines_of_code']).to be_kind_of(Integer)
          expect(metrics['lines_of_code']).to eq(5) # Accounts for the actual lines in the file
        end
      end

      it 'calculates higher abc size for a complex file' do
        Dir.mktmpdir do |dir|
          file_path = File.join(dir, 'complex.rb')
          content = <<~RUBY
            def complex_method(x)
              result = []

              if x > 10
                y = x * 2
                result << y
              elsif x < 0
                y = x.abs
                result << y
              else
                result << x
              end

              while result.size < 5
                result << x
              end

              result
            end
          RUBY

          File.write(file_path, content)

          metrics = described_class.calculate_for_file(file_path)
          expect(metrics['abc_size']).to be_kind_of(Numeric)
          expect(metrics['abc_size']).to be > 2 # Should be more complex than simple file
          expect(metrics['lines_of_code']).to be_kind_of(Integer)
          expect(metrics['lines_of_code']).to eq(19) # Accounts for the actual lines in the file
        end
      end
    end

    describe '.calculate_for_feature' do
      it 'returns 0 for empty file list' do
        expect(described_class.calculate_for_feature([])).to eq({ 'abc_size' => 0, 'lines_of_code' => 0 })
      end

      it 'calculates abc_size for a feature with files of varying ABC size' do
        Dir.mktmpdir do |dir|
          # Simple file (low ABC)
          simple_path = File.join(dir, 'simple.rb')
          File.write(simple_path, <<~RUBY)
            def simple_method
              x = 1
              y = 2
              x + y
            end
          RUBY

          # Complex file (higher ABC)
          complex_path = File.join(dir, 'complex.rb')
          File.write(complex_path, <<~RUBY)
            def complex_method(x)
              result = []
              if x > 10
                y = x * 2
                result << y
              elsif x < 0
                y = x.abs
                result << y
              end
              result
            end
          RUBY

          metrics = described_class.calculate_for_feature([simple_path, complex_path])

          puts "\nFeature ABC Size Calculation:"
          puts "Simple file ABC: #{described_class.calculate_for_file(simple_path)['abc_size']}"
          puts "Complex file ABC: #{described_class.calculate_for_file(complex_path)['abc_size']}"
          puts "Overall Feature ABC Size: #{metrics['abc_size']}"

          expect(metrics['abc_size']).to be_kind_of(Numeric)
          expect(metrics['abc_size']).to be > 0
          expect(metrics['lines_of_code']).to be_kind_of(Integer)
          expect(metrics['lines_of_code']).to be > 0
        end
      end

      it 'sums ABC metrics for all files within the feature' do
        Dir.mktmpdir do |dir|
          # Very simple file
          very_simple_path = File.join(dir, 'very_simple.rb')
          File.write(very_simple_path, <<~RUBY)
            def greet
              message = "hello"

              puts message
            end
          RUBY

          # Moderately complex file
          moderate_path = File.join(dir, 'moderate.rb')
          File.write(moderate_path, <<~RUBY)
            def process_list(items)
              result = []
              items.each do |item|
                if item.valid?
                  result << item.transform
                else
                  result << item.default_value
                end
              end
              result.compact
            end
          RUBY

          # Very complex file
          very_complex_path = File.join(dir, 'very_complex.rb')
          File.write(very_complex_path, <<~RUBY)
            def complex_operation(data)
              result = {}
              data.each do |key, values|
                temp = values.map do |v|
                  if v.is_a?(String)
                    v.upcase
                  elsif v.is_a?(Numeric)
                    v * 2
                  else
                    v.to_s
                  end
                end

                result[key] = if temp.all? { |t| t.to_i.even? }
                  temp.sum
                else
                  temp.join('-')
                end
              end
              result
            end
          RUBY

          simple_feature = described_class.calculate_for_feature([very_simple_path])
          moderate_feature = described_class.calculate_for_feature([very_simple_path, moderate_path])
          complex_feature = described_class.calculate_for_feature([very_simple_path, moderate_path, very_complex_path])

          expect(simple_feature).to eq({
                                         'abc_size' => 1.41,
                                         'lines_of_code' => 5
                                       })

          expect(moderate_feature).to eq({
                                           'abc_size' => 9.6,
                                           'lines_of_code' => 16
                                         })

          expect(complex_feature).to eq({
                                          'abc_size' => 26.83,
                                          'lines_of_code' => 37
                                        })
        end
      end
    end
  end
end
