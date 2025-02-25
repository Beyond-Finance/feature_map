# frozen_string_literal: true

require 'spec_helper'

module FeatureMap
  RSpec.describe Private::AssignmentApplicator do
    before do
      # Must use the skip_features_validation to avoid having the GlobCache loaded from the stub assignments.yml file.
      write_configuration('skip_features_validation' => true)
      create_files_with_defined_classes
    end

    describe '.apply_assignments!' do
      context 'when assigning to a directory' do
        it 'injects .feature file into an empty directory' do
          Dir.mktmpdir('assignment_test') do |dir|
            feature_path = File.join(dir, '.feature')
            expect(File.exist?(feature_path)).to eq(false)

            assignments = [[dir.to_s, 'Foo']]
            described_class.apply_assignments!(assignments)

            expect(File.read(feature_path)).to eq("Foo\n")
          end
        end

        it 'overwrites an existing .feature file' do
          Dir.mktmpdir('assignment_test') do |dir|
            feature_path = File.join(dir, '.feature')
            write_file(feature_path, "Bar\n")

            assignments = [[dir.to_s, 'Foo']]
            described_class.apply_assignments!(assignments)

            expect(File.read(feature_path)).to eq("Foo\n")
          end
        end
      end

      context 'when assigning into a .cls file' do
        it 'places feature assignment at the top of the file' do
          write_file('app/test.cls', <<~CONTENTS)
            global class HelloWorld {
              public String hello() {
                return 'Hello World!';
              }
            }
          CONTENTS

          described_class.apply_assignments!([['app/test.cls', 'Foo']])

          expect(File.read('app/test.cls')).to eq(<<~CONTENTS)
            // @feature Foo

            global class HelloWorld {
              public String hello() {
                return 'Hello World!';
              }
            }
          CONTENTS
        end

        it 'ignores files that already have an assignment' do
          write_file('app/test.cls', <<~CONTENTS)
            // @feature Bar

            global class HelloWorld {
              public String hello() {
                return 'Hello World!';
              }
            }
          CONTENTS

          expect do
            described_class.apply_assignments!([['app/test.cls', 'Foo']])
          end.to output("Already assigned: app/test.cls, Foo\n").to_stdout

          expect(File.read('app/test.cls')).to eq(<<~CONTENTS)
            // @feature Bar

            global class HelloWorld {
              public String hello() {
                return 'Hello World!';
              }
            }
          CONTENTS
        end
      end

      context 'when assigning into a .html file' do
        it 'places feature assignment at the top of the file' do
          write_file('app/test.html', <<~CONTENTS)
            <!DOCTYPE html>
            <html>
                <head>
                    <title>Example</title>
                </head>
                <body>
                    <p>This is an example of a simple HTML page with one paragraph.</p>
                </body>
            </html>
          CONTENTS

          described_class.apply_assignments!([['app/test.html', 'Foo']])

          expect(File.read('app/test.html')).to eq(<<~CONTENTS)
            <!-- @feature Foo -->

            <!DOCTYPE html>
            <html>
                <head>
                    <title>Example</title>
                </head>
                <body>
                    <p>This is an example of a simple HTML page with one paragraph.</p>
                </body>
            </html>
          CONTENTS
        end

        it 'ignores files that already have an assignment' do
          write_file('app/test.html', <<~CONTENTS)
            <!-- @feature Bar -->

            <!DOCTYPE html>
            <html>
                <head>
                    <title>Example</title>
                </head>
                <body>
                    <p>This is an example of a simple HTML page with one paragraph.</p>
                </body>
            </html>
          CONTENTS

          expect do
            described_class.apply_assignments!([['app/test.html', 'Foo']])
          end.to output("Already assigned: app/test.html, Foo\n").to_stdout

          expect(File.read('app/test.html')).to eq(<<~CONTENTS)
            <!-- @feature Bar -->

            <!DOCTYPE html>
            <html>
                <head>
                    <title>Example</title>
                </head>
                <body>
                    <p>This is an example of a simple HTML page with one paragraph.</p>
                </body>
            </html>
          CONTENTS
        end
      end

      %w[js jsx ts tsx].each do |jslike_filetype|
        context "when assigning into a .#{jslike_filetype} file" do
          it 'places feature assignment at the top of the file' do
            write_file("app/test.#{jslike_filetype}", <<~CONTENTS)
              class Rectangle {
                constructor(height, width) {
                  this.height = height;
                  this.width = width;
                }
              }
            CONTENTS

            described_class.apply_assignments!([["app/test.#{jslike_filetype}", 'Foo']])

            expect(File.read("app/test.#{jslike_filetype}")).to eq(<<~CONTENTS)
              // @feature Foo

              class Rectangle {
                constructor(height, width) {
                  this.height = height;
                  this.width = width;
                }
              }
            CONTENTS
          end

          it 'ignores files that already have an assignment' do
            write_file("app/test.#{jslike_filetype}", <<~CONTENTS)
              // @feature Bar

              class Rectangle {
                constructor(height, width) {
                  this.height = height;
                  this.width = width;
                }
              }
            CONTENTS

            expect do
              described_class.apply_assignments!([["app/test.#{jslike_filetype}", 'Foo']])
            end.to output("Already assigned: app/test.#{jslike_filetype}, Foo\n").to_stdout

            expect(File.read("app/test.#{jslike_filetype}")).to eq(<<~CONTENTS)
              // @feature Bar

              class Rectangle {
                constructor(height, width) {
                  this.height = height;
                  this.width = width;
                }
              }
            CONTENTS
          end
        end
      end

      context 'when assigning into a .rb file' do
        it 'places feature assignment at the top of the file' do
          write_file('app/test.rb', <<~CONTENTS)
            # frozen_string_literal: true

            class Foo
              def initialize(val)
                @val = val
              end
            end
          CONTENTS

          described_class.apply_assignments!([['app/test.rb', 'Foo']])

          expect(File.read('app/test.rb')).to eq(<<~CONTENTS)
            # @feature Foo
            # frozen_string_literal: true

            class Foo
              def initialize(val)
                @val = val
              end
            end
          CONTENTS
        end

        it 'ignores files that already have an assignment' do
          write_file('app/test.rb', <<~CONTENTS)
            # @feature Bar
            # frozen_string_literal: true

            class Foo
              def initialize(val)
                @val = val
              end
            end
          CONTENTS

          expect do
            described_class.apply_assignments!([['app/test.rb', 'Foo']])
          end.to output("Already assigned: app/test.rb, Foo\n").to_stdout

          expect(File.read('app/test.rb')).to eq(<<~CONTENTS)
            # @feature Bar
            # frozen_string_literal: true

            class Foo
              def initialize(val)
                @val = val
              end
            end
          CONTENTS
        end
      end

      context 'when assigning into a .xml file' do
        it 'places feature assignment after xml declaration if available' do
          write_file('app/test.xml', <<~CONTENTS)
            <?xml version="1.0" encoding="UTF-8"?>
            <Thing>
              <InnerThing />
            </Thing>
          CONTENTS

          write_file('app/test-missing-xml.xml', <<~CONTENTS)
            <Thing>
              <InnerThing />
            </Thing>
          CONTENTS

          write_file('app/test-top-comment.xml', <<~CONTENTS)
            <!--
              A long
              multiline
              comment
            -->
            <?xml version="1.0" encoding="UTF-8"?>
            <Thing>
              <InnerThing />
            </Thing>
          CONTENTS

          described_class.apply_assignments!([['app/test.xml', 'Foo'], ['app/test-missing-xml.xml', 'Foo'], ['app/test-top-comment.xml', 'Foo']])

          expect(File.read('app/test.xml')).to eq(<<~CONTENTS)
            <?xml version="1.0" encoding="UTF-8"?>
            <!-- @feature Foo -->

            <Thing>
              <InnerThing />
            </Thing>
          CONTENTS

          expect(File.read('app/test-missing-xml.xml')).to eq(<<~CONTENTS)
            <!-- @feature Foo -->

            <Thing>
              <InnerThing />
            </Thing>
          CONTENTS

          expect(File.read('app/test-top-comment.xml')).to eq(<<~CONTENTS)
            <!--
              A long
              multiline
              comment
            -->
            <?xml version="1.0" encoding="UTF-8"?>
            <!-- @feature Foo -->

            <Thing>
              <InnerThing />
            </Thing>
          CONTENTS
        end

        it 'ignores files that already have an assignment' do
          write_file('app/test.xml', <<~CONTENTS)
            <?xml version="1.0" encoding="UTF-8"?>
            <!-- @feature Bar -->

            <Thing>
              <InnerThing />
            </Thing>
          CONTENTS

          expect do
            described_class.apply_assignments!([['app/test.xml', 'Foo']])
          end.to output("Already assigned: app/test.xml, Foo\n").to_stdout

          expect(File.read('app/test.xml')).to eq(<<~CONTENTS)
            <?xml version="1.0" encoding="UTF-8"?>
            <!-- @feature Bar -->

            <Thing>
              <InnerThing />
            </Thing>
          CONTENTS
        end
      end
    end
  end
end
