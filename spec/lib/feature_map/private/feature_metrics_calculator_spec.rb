require 'spec_helper'
require 'tmpdir'

module FeatureMap
  RSpec.describe Private::FeatureMetricsCalculator do
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
          expect(metrics['lines_of_code']).to eq(5) # Counts all non-whitespace, non-comment lines
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
          expect(metrics['lines_of_code']).to eq(16) # Counts all non-whitespace, non-comment lines
        end
      end

      it 'calculates lines of code for non-ruby files' do
        Dir.mktmpdir do |dir|
          file_path = File.join(dir, 'layout.html.erb')
          content = <<~HTML
            <!--
            @feature Doc Send
            -->
            <!DOCTYPE html>
            <html>
              <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                <style>

                </style>
              </head>

              <body>
                <%= yield %>
              </body>
            </html>
          HTML

          File.write(file_path, content)

          metrics = described_class.calculate_for_file(file_path)
          expect(metrics['abc_size']).to be_nil
          expect(metrics['cyclomatic_complexity']).to be_nil
          expect(metrics['lines_of_code']).to eq(11) # Counts all non-whitespace, non-comment lines
        end
      end

      it 'aggregates TODO locations across files' do
        Dir.mktmpdir do |dir|
          file1_path = File.join(dir, 'file1.rb')
          File.write(file1_path, <<~RUBY)
            # TODO: Fix this method
            def method1
              puts "hello"
            end
          RUBY

          file2_path = File.join(dir, 'file2.rb')
          File.write(file2_path, <<~RUBY)
            # TODO: Refactor later
            # TODO: Add error handling
            def method2
              raise "Not implemented"
            end
          RUBY

          metrics = described_class.calculate_for_feature([file1_path, file2_path])
          expect(metrics['todo_locations'].length).to eq(3)
        end
      end
    end

    describe '.calculate_for_feature' do
      it 'returns 0 for empty file list' do
        expect(described_class.calculate_for_feature([])).to eq({
                                                                  'abc_size' => 0,
                                                                  'lines_of_code' => 0,
                                                                  'cyclomatic_complexity' => 0,
                                                                  'todo_locations' => {}
                                                                })
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
                                         'lines_of_code' => 4,
                                         'cyclomatic_complexity' => 1,
                                         'todo_locations' => {}
                                       })

          expect(moderate_feature).to eq({
                                           'abc_size' => 9.6,
                                           'lines_of_code' => 15,
                                           'cyclomatic_complexity' => 3,
                                           'todo_locations' => {}
                                         })

          expect(complex_feature).to eq({
                                          'abc_size' => 26.83,
                                          'lines_of_code' => 35,
                                          'cyclomatic_complexity' => 7,
                                          'todo_locations' => {}
                                        })
        end
      end
    end
  end
end
