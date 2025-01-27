# typed: false
# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::TodoInspector do
    include TempFileHelpers

    let(:inspector) { described_class.new(file_path) }
    let(:file_path) { 'app/todo_inspector_test.rb' }

    describe '#calculate' do
      it 'detects single-line Ruby TODO comments' do
        with_temp_file(content: <<~RUBY) do |path|
          # TODO: Fix this method
          def some_method
            # This is not worth considering
            puts "hello"
            # TODO Make this better
          end
        RUBY
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(2)
          expect(todos).to include(
            "#{path}:1" => 'Fix this method',
            "#{path}:5" => 'Make this better'
          )
        end
      end

      it 'detects single-line JavaScript TODO comments' do
        with_temp_file(content: <<~JS) do |path|
          // TODO: Update API endpoint
          function test() {
            // TODO Fix error handling
          }
        JS
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(2)
          expect(todos).to include(
            "#{path}:1" => 'Update API endpoint',
            "#{path}:3" => 'Fix error handling'
          )
        end
      end

      it 'detects multi-line C-style TODO comments' do
        with_temp_file(content: <<~CODE) do |path|
          /*
           * TODO: Implement caching
           * This is a multi-line comment
           */
          class Something {
            /* TODO: Another todo here */
          }
        CODE
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(2)
          expect(todos).to include(
            "#{path}:2" => 'Implement caching',
            "#{path}:6" => 'Another todo here'
          )
        end
      end

      it 'detects HTML-style TODO comments' do
        with_temp_file(content: <<~HTML) do |path|
          <!-- TODO: Add responsive styles -->
          <div>
            <!-- TODO Fix accessibility -->
          </div>
        HTML
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(2)
          expect(todos).to include(
            "#{path}:1" => 'Add responsive styles',
            "#{path}:3" => 'Fix accessibility'
          )
        end
      end

      it 'does not detect Python-style multi-line TODO comments' do
        with_temp_file(content: <<~PYTHON) do |path|
          '''
          TODO: Add type hints
          This is a multi-line comment
          '''
          """
          TODO: Add docstring
          """
        PYTHON
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(0)
          expect(todos).to be_empty
        end
      end

      it 'handles files with mixed comment styles' do
        with_temp_file(content: <<~MIXED) do |path|
          # TODO: First todo
          /* TODO: Second todo */
          // TODO: Third todo
          <!--
          TODO: Fourth todo
          -->
        MIXED
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(4)
          expect(todos).to include(
            "#{path}:1" => 'First todo',
            "#{path}:2" => 'Second todo',
            "#{path}:3" => 'Third todo',
            "#{path}:5" => 'Fourth todo'
          )
        end
      end

      it 'returns empty results for files with no TODOs' do
        with_temp_file(content: <<~CODE) do |path|
          # Just a comment
          /* Regular comment */
          // Nothing special
        CODE
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(0)
          expect(todos).to be_empty
        end
      end

      it 'returns empty results for empty files' do
        with_temp_file(content: '') do |path|
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(0)
          expect(todos).to be_empty
        end
      end

      it 'handles TODO without colon' do
        with_temp_file(content: '# TODO fix this') do |path|
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(1)
          expect(todos).to include("#{path}:1" => 'fix this')
        end
      end

      it 'handles extra whitespace' do
        with_temp_file(content: '#    TODO:    spacing test    ') do |path|
          inspector = described_class.new(path)
          count, todos = inspector.calculate

          expect(count).to eq(1)
          expect(todos).to include("#{path}:1" => 'spacing test')
        end
      end

      it 'raises error for non-existent files' do
        inspector = described_class.new('non_existent_file.rb')
        expect { inspector.calculate }.to raise_error(Errno::ENOENT)
      end
    end
  end
end
