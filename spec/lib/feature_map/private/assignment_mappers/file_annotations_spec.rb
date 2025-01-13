module FeatureMap
  RSpec.shared_examples 'an identifiable feature' do
    let(:feature_filepath) { feature.gsub(/ /, '_').downcase }
    let(:feature_annotation) { annotation.gsub('__FEATURE__', feature) }

    context 'when the feature assignment comment is on one of the first three lines' do
      before do
        write_configuration
        write_file(".feature_map/definitions/#{feature_filepath}.yml", <<~CONTENTS)
          name: #{feature}
        CONTENTS

        preceding_lines = ['# @team My Team', '# Test Comment'].take(rand(0..2))
        write_file('packs/my_pack/assigned_file.rb', <<~CONTENTS)
          #{preceding_lines.join("\n")}
          @feature Feature Without Comment - Should Be Skipped
          #{feature_annotation}
        CONTENTS
      end

      describe '.for_feature' do
        it 'prints out feature report for the given feature' do
          expect(FeatureMap.for_feature(feature)).to eq <<~FEATURE_REPORT
            # Report for `#{feature}` Feature
            ## Annotations at the top of file
            - packs/my_pack/assigned_file.rb

            ## Feature-specific assigned globs
            This feature does not have any files in this category.

            ## Feature Assigned in .feature
            This feature does not have any files in this category.

            ## Feature definition file assignment
            - .feature_map/definitions/#{feature_filepath}.yml
          FEATURE_REPORT
        end
      end

      describe '.for_file' do
        it 'can find the assigned feature of a ruby file with file annotations' do
          expect(FeatureMap.for_file('packs/my_pack/assigned_file.rb').name).to eq(feature)
        end
      end
    end

    context 'when the feature assignment comment is on the eleventh lines' do
      before do
        write_configuration
        write_file(".feature_map/definitions/#{feature_filepath}.yml", <<~CONTENTS)
          name: #{feature}
        CONTENTS

        write_file('packs/my_pack/assigned_file.rb', <<~CONTENTS)
          # @team My Team
          # Test Comment
          # Another Test Comment
          # @team My Team
          # Test Comment
          # Another Test Comment
          # @team My Team
          # Test Comment
          # Another Test Comment
          # @team My Team
          # Test Comment
          #{feature_annotation}
        CONTENTS
      end

      describe '.for_feature' do
        it 'does not detect the feature assignment' do
          expect(FeatureMap.for_feature(feature)).to eq <<~FEATURE_REPORT
            # Report for `#{feature}` Feature
            ## Annotations at the top of file
            This feature does not have any files in this category.

            ## Feature-specific assigned globs
            This feature does not have any files in this category.

            ## Feature Assigned in .feature
            This feature does not have any files in this category.

            ## Feature definition file assignment
            - .feature_map/definitions/#{feature_filepath}.yml
          FEATURE_REPORT
        end
      end

      describe '.for_file' do
        it 'does NOT find the assigned feature' do
          expect(FeatureMap.for_file('packs/my_pack/assigned_file.rb')).to be_nil
        end
      end
    end
  end

  RSpec.describe Private::AssignmentMappers::FileAnnotations do
    {
      ruby_inline: '# @feature __FEATURE__',
      javascript_inline: '// @feature __FEATURE__',
      javascript_multiline_single: '/* @feature __FEATURE__ */',
      html_multiline_single: '<!-- @feature __FEATURE__ -->',
      python_double_quote_single: '""" @feature __FEATURE__ """',
      python_single_quote_single: "''' @feature __FEATURE__ '''"
      # TODO:  Consider adding support for feature assignment
      #        multiline comment blocks.
      # html_multiline_multiple: "<!--\n@feature __FEATURE__\n-->",
      # javascript_multiline_multiple: "/*\n@feature __FEATURE__\n*/",
      # python_double_quote_single: '"""\n@feature __FEATURE__\n"""',
      # python_single_quote_single: "'''\n@feature __FEATURE__\n'''"
    }.each do |comment_language, language_annotation|
      context "with comments in #{comment_language}" do
        it_behaves_like 'an identifiable feature' do
          let(:annotation) { language_annotation }
          let(:feature) { 'Bar' }
        end
      end
    end

    describe '.remove_file_annotation!' do
      subject(:remove_file_annotation) do
        FeatureMap.remove_file_annotation!(filename)
        # Getting the feature gets stored in the cache, so after we remove the file annotation we want to bust the cache
        FeatureMap.bust_caches!
      end

      before do
        write_file('.feature_map/definitions/foo.yml', <<~CONTENTS)
          name: Foo
        CONTENTS
        write_configuration
      end

      context 'file has no annotation' do
        let(:filename) { 'app/my_file.rb' }

        before do
          write_file(filename, <<~CONTENTS)
            # Empty file
          CONTENTS
        end

        it 'has no effect' do
          expect(File.read(filename)).to eq "# Empty file\n"

          remove_file_annotation

          expect(File.read(filename)).to eq "# Empty file\n"
        end
      end

      context 'file has annotation' do
        let(:filename) { 'app/my_file.rb' }

        before do
          write_file(filename, <<~CONTENTS)
            # @feature Foo

            # Some content
          CONTENTS

          write_file('package.yml', <<~CONTENTS)
            enforce_dependency: true
            enforce_privacy: true
          CONTENTS
        end

        it 'removes the annotation' do
          current_assigned_feature = FeatureMap.for_file(filename)
          expect(current_assigned_feature&.name).to eq 'Foo'
          expect(File.read(filename)).to eq <<~RUBY
            # @feature Foo

            # Some content
          RUBY

          remove_file_annotation

          new_assigned_feature = FeatureMap.for_file(filename)
          expect(new_assigned_feature).to eq nil
          expected_output = <<~RUBY
            # Some content
          RUBY

          expect(File.read(filename)).to eq expected_output
        end
      end

      context 'file has new lines after the annotation' do
        let(:filename) { 'app/my_file.rb' }

        before do
          write_file(filename, <<~CONTENTS)
            # @feature Foo


            # Some content


            # Some other content
          CONTENTS
        end

        it 'removes the annotation and the leading new lines' do
          expect(File.read(filename)).to eq <<~RUBY
            # @feature Foo


            # Some content


            # Some other content
          RUBY

          remove_file_annotation

          expected_output = <<~RUBY
            # Some content


            # Some other content
          RUBY

          expect(File.read(filename)).to eq expected_output
        end
      end
    end
  end
end
