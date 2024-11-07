RSpec.describe FeatureMap do
  # Look at individual validations spec to see other validaions that ship with FeatureMap
  describe '.validate!' do
    describe 'features must exist validation' do
      before do
        write_file('config/features/bar.yml', <<~CONTENTS)
          name: Bar
        CONTENTS

        write_configuration
      end

      context 'directory with [] characters' do
        before do
          write_file('app/services/.feature', <<~CONTENTS)
            Bar
          CONTENTS
          write_file('app/services/test/some_unassigned_file.rb', '')
          write_file('app/services/[test]/some_unassigned_file.rb', '')
        end

        it 'has no validation errors' do
          expect { FeatureMap.validate!(files: ['app/services/test/some_unassigned_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate!(files: ['app/services/[test]/some_unassigned_file.rb']) }.to_not raise_error
        end
      end

      context 'directory with [] characters containing a .feature file' do
        before do
          write_file('app/services/[test]/.feature', <<~CONTENTS)
            Bar
          CONTENTS
          write_file('app/services/[test]/some_file.rb', '')
        end

        it 'has no validation errors' do
          expect { FeatureMap.validate!(files: ['app/services/[test]/some_file.rb']) }.to_not raise_error
        end
      end

      context 'file assignment with [] characters' do
        before do
          write_file('app/services/[test]/some_file.ts', <<~TYPESCRIPT)
            // @feature Bar
            // Countries
          TYPESCRIPT
        end

        it 'has no validation errors' do
          expect { FeatureMap.validate!(files: ['app/services/withoutbracket/some_other_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate!(files: ['app/services/[test]/some_other_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate!(files: ['app/services/*/some_other_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate!(files: ['app/*/[test]/some_other_file.rb']) }.to_not raise_error
          expect { FeatureMap.validate! }.to_not raise_error
        end
      end

      context 'invalid feature in a file annotation' do
        before do
          write_file('app/some_file.rb', <<~CONTENTS)
            # @feature Foo
          CONTENTS
        end

        it 'lets the user know the feature cannot be found in the file' do
          expect { FeatureMap.validate! }.to raise_error do |e|
            expect(e).to be_a StandardError
            expect(e.message).to eq <<~EXPECTED.chomp
              Could not find feature with name: `Foo` in app/some_file.rb. Make sure the feature is one of `["Bar"]`
            EXPECTED
          end
        end
      end
    end

    context 'file is unassigned' do
      before do
        write_file('config/features/bar.yml', <<~CONTENTS)
          name: Bar
        CONTENTS

        write_configuration

        write_file('app/services/autogenerated_code/some_unassigned_file.rb', '')
      end

      it 'has no validation errors' do
        expect { FeatureMap.validate!(files: ['app/services/autogenerated_code/some_unassigned_file.rb']) }.to raise_error do |e|
          expect(e.message).to eq <<~MSG.chomp
            Some files are missing a feature assignment:

            - app/services/autogenerated_code/some_unassigned_file.rb

            See https://github.com/Beyond-Finance/feature_map#README.md for more details
          MSG
        end
      end

      context 'ignored file passed in that is ignored' do
        before do
          write_configuration('unassigned_globs' => ['app/services/autogenerated_code/**/**', 'vendor/bundle/**/**'])
        end

        it 'has no validation errors' do
          expect { FeatureMap.validate!(files: ['app/services/autogenerated_code/some_unassigned_file.rb']) }.to_not raise_error
        end
      end
    end
  end

  # See tests for individual assignment_mappers to understand behavior for each mapper
  describe '.for_file' do
    describe 'path formatting expectations' do
      # All file paths must be clean paths relative to the root: https://apidock.com/ruby/Pathname/cleanpath
      it 'will not find the assignment of a file that is not a cleanpath' do
        expect(FeatureMap.for_file('packs/my_pack/assigned_file.rb')).to eq FeatureMap::CodeFeatures.find('Bar')
        expect(FeatureMap.for_file('./packs/my_pack/assigned_file.rb')).to eq nil
      end
    end

    context '.feature in a directory with [] characters' do
      before do
        write_file('app/javascript/[test]/.feature', <<~CONTENTS)
          Bar
        CONTENTS
        write_file('app/javascript/[test]/test.js', '')
      end
 
      it 'properly assigns feature' do
        expect(FeatureMap.for_file('app/javascript/[test]/test.js')).to eq FeatureMap::CodeFeatures.find('Bar')
      end
    end

    before { create_non_empty_application }
  end

  describe '.for_backtrace' do
    before do
      create_files_with_defined_classes
      write_configuration
    end

    context 'excluded_features is not passed in as an input parameter' do
      it 'finds the right feature' do
        expect { MyFile.raise_error }.to raise_error do |ex|
          expect(FeatureMap.for_backtrace(ex.backtrace)).to eq FeatureMap::CodeFeatures.find('Bar')
        end
      end
    end

    context 'excluded_features is passed in as an input parameter' do
      it 'ignores the first part of the stack trace and finds the next viable feature' do
        expect { MyFile.raise_error }.to raise_error do |ex|
          feature_to_exclude = FeatureMap::CodeFeatures.find('Bar')
          expect(FeatureMap.for_backtrace(ex.backtrace, excluded_features: [feature_to_exclude])).to eq FeatureMap::CodeFeatures.find('Foo')
        end
      end
    end
  end

  describe '.first_assigned_file_for_backtrace' do
    before do
      write_configuration
      create_files_with_defined_classes
    end

    context 'excluded_features is not passed in as an input parameter' do
      it 'finds the right feature' do
        expect { MyFile.raise_error }.to raise_error do |ex|
          expect(FeatureMap.first_assigned_file_for_backtrace(ex.backtrace)).to eq [FeatureMap::CodeFeatures.find('Bar'), 'app/my_error.rb']
        end
      end
    end

    context 'excluded_features is not passed in as an input parameter' do
      it 'finds the right feature' do
        expect { MyFile.raise_error }.to raise_error do |ex|
          feature_to_exclude = FeatureMap::CodeFeatures.find('Bar')
          expect(FeatureMap.first_assigned_file_for_backtrace(ex.backtrace, excluded_features: [feature_to_exclude])).to eq [FeatureMap::CodeFeatures.find('Foo'), 'app/my_file.rb']
        end
      end
    end

    context 'when nothing is assigned a feature' do
      it 'returns nil' do
        expect { raise 'opsy' }.to raise_error do |ex|
          expect(FeatureMap.first_assigned_file_for_backtrace(ex.backtrace)).to be_nil
        end
      end
    end
  end

  describe '.for_class' do
    before do
      create_files_with_defined_classes
      write_configuration
      # binding.break
    end

    it 'can find the right feature for a class' do
      expect(FeatureMap.for_class(MyFile)).to eq FeatureMap::CodeFeatures.find('Foo')
    end

    it 'memoizes the values' do
      expect(FeatureMap.for_class(MyFile)).to eq FeatureMap::CodeFeatures.find('Foo')
      allow(FeatureMap).to receive(:for_file)
      allow(Object).to receive(:const_source_location)
      expect(FeatureMap.for_class(MyFile)).to eq FeatureMap::CodeFeatures.find('Foo')

      # Memoization should avoid these calls
      expect(FeatureMap).to_not have_received(:for_file)
      expect(Object).to_not have_received(:const_source_location)
    end

    it 'returns nil if the class constant cannot be found' do
      allow(FeatureMap).to receive(:for_file)
      allow(Object).to receive(:const_source_location).and_raise(NameError)
      expect(FeatureMap.for_class(MyFile)).to eq nil
    end
  end

  describe '.for_feature' do
    before { create_non_empty_application }

    it 'prints out feature report for the given feature' do
      expect(FeatureMap.for_feature('Bar')).to eq <<~FEATURE_REPORT
        # Report for `Bar` Feature
        ## Annotations at the top of file
        - frontend/javascripts/packages/my_package/assigned_file.jsx
        - packs/my_pack/assigned_file.rb

        ## Feature Assigned in .feature
        - directory/my_feature/**/**

        ## Feature YML assignment
        - config/features/bar.yml
      FEATURE_REPORT
    end
  end
end
