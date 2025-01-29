# typed: false
# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::TodoInspector do
    let(:inspector) { described_class.new(file_path) }
    let(:file_path) { 'app/todo_inspector_test.rb' }

    describe '#calculate' do
      it 'detects single-line Ruby TODO comments' do
        path = write_file('test.rb', <<~RUBY)
          # TODO: Fix this method
          def some_method
            # This is not worth considering
            puts "hello"
            # TODO Make this better
          end
        RUBY
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to include(
          "#{path}:1" => 'Fix this method',
          "#{path}:5" => 'Make this better'
        )
      end

      it 'detects single-line JavaScript TODO comments' do
        path = write_file('test.js', <<~JS)
          // TODO: Update API endpoint
          function test() {
            // TODO Fix error handling
          }
        JS
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to include(
          "#{path}:1" => 'Update API endpoint',
          "#{path}:3" => 'Fix error handling'
        )
      end

      it 'detects multi-line C-style TODO comments' do
        path = write_file('test.txt', <<~CODE)
          /*
           * TODO: Implement caching
           * This is a multi-line comment
           */
          class Something {
            /* TODO: Another todo here */
          }
        CODE
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to include(
          "#{path}:2" => 'Implement caching',
          "#{path}:6" => 'Another todo here'
        )
      end

      it 'detects HTML-style TODO comments' do
        path = write_file('test.html', <<~HTML)
          <!-- TODO: Add responsive styles -->
          <div>
            <!-- TODO Fix accessibility -->
          </div>
        HTML
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to include(
          "#{path}:1" => 'Add responsive styles',
          "#{path}:3" => 'Fix accessibility'
        )
      end

      it 'does not detect Python-style multi-line TODO comments' do
        path = write_file('test.py', <<~PYTHON)
          '''
          TODO: Add type hints
          This is a multi-line comment
          '''
          """
          TODO: Add docstring
          """
        PYTHON
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to be_empty
      end

      it 'handles files with mixed comment styles' do
        path = write_file('test.txt', <<~MIXED)
          # TODO: First todo
          /* TODO: Second todo */
          // TODO: Third todo
          <!--
          TODO: Fourth todo
          -->
        MIXED
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to include(
          "#{path}:1" => 'First todo',
          "#{path}:2" => 'Second todo',
          "#{path}:3" => 'Third todo',
          "#{path}:5" => 'Fourth todo'
        )
      end

      it 'returns empty results for files with no TODOs' do
        path = write_file('test.txt', <<~CODE)
          # Just a comment
          /* Regular comment */
          // Nothing special
        CODE
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to be_empty
      end

      it 'returns empty results for empty files' do
        path = write_file('test.txt', '')
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to be_empty
      end

      it 'handles TODO without colon' do
        path = write_file('test.txt', '# TODO fix this')
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to include("#{path}:1" => 'fix this')
      end

      it 'handles extra whitespace' do
        path = write_file('test.txt', '#    TODO:    spacing test    ')
        inspector = described_class.new(path)
        todos = inspector.calculate

        expect(todos).to include("#{path}:1" => 'spacing test')
      end

      it 'raises error for non-existent files' do
        inspector = described_class.new('non_existent_file.rb')
        expect { inspector.calculate }.to raise_error(Errno::ENOENT)
      end
    end
  end
end
