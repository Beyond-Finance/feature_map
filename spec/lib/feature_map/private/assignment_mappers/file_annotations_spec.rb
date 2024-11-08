module FeatureMap
  RSpec.describe Private::AssignmentMappers::FileAnnotations do
    describe '.for_feature' do
      before do
        write_configuration
        write_file('config/features/bar.yml', <<~CONTENTS)
          name: Bar
        CONTENTS

        write_file('packs/my_pack/assigned_file.rb', <<~CONTENTS)
          # @feature Bar
        CONTENTS
      end

      it 'prints out feature report for the given feature' do
        expect(FeatureMap.for_feature('Bar')).to eq <<~FEATURE_REPORT
          # Report for `Bar` Feature
          ## Annotations at the top of file
          - packs/my_pack/assigned_file.rb

          ## Feature-specific assigned globs
          This feature does not have any files in this category.

          ## Feature Assigned in .feature
          This feature does not have any files in this category.

          ## Feature YML assignment
          - config/features/bar.yml
        FEATURE_REPORT
      end
    end

    describe '.for_file' do
      before do
        write_configuration
        write_file('config/features/bar.yml', <<~CONTENTS)
          name: Bar
        CONTENTS

        write_file('packs/my_pack/assigned_file.rb', <<~CONTENTS)
          # @feature Bar
        CONTENTS
      end

      it 'can find the assigned feature of a ruby file with file annotations' do
        expect(FeatureMap.for_file('packs/my_pack/assigned_file.rb').name).to eq 'Bar'
      end
    end

    describe '.remove_file_annotation!' do
      subject(:remove_file_annotation) do
        FeatureMap.remove_file_annotation!(filename)
        # Getting the feature gets stored in the cache, so after we remove the file annotation we want to bust the cache
        FeatureMap.bust_caches!
      end

      before do
        write_file('config/features/foo.yml', <<~CONTENTS)
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
