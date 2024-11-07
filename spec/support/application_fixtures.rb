RSpec.shared_context 'application fixtures' do
  let(:features_file_path) { Pathname.pwd.join('FEATURES.yml') }

  def write_configuration(assigned_globs: nil, **kwargs)
    assigned_globs ||= ['{app,components,config,frontend,lib,packs,spec}/**/*.{rb,rake,js,jsx,ts,tsx,json,yml}']
    config = {
      'assigned_globs' => assigned_globs,
      'unassigned_globs' => ['config/feature_map.yml']
    }.merge(kwargs)
    write_file('config/feature_map.yml', config.to_yaml)
  end

  let(:create_non_empty_application) do
    write_configuration

    write_file('frontend/javascripts/packages/my_package/assigned_file.jsx', <<~CONTENTS)
      // @feature Bar
    CONTENTS

    write_file('packs/my_pack/assigned_file.rb', <<~CONTENTS)
      # @feature Bar
    CONTENTS

    write_file('directory/my_feature/.feature', <<~CONTENTS)
      Bar
    CONTENTS
    write_file('directory/my_feature/some_directory_file.ts')

    write_file('frontend/javascripts/packages/my_other_package/package.json', <<~CONTENTS)
      {
        "name": "@gusto/my_package",
        "metadata": {
          "feature": "Bar"
        }
      }
    CONTENTS
    write_file('frontend/javascripts/packages/my_other_package/my_file.jsx')

    write_file('config/features/bar.yml', <<~CONTENTS)
      name: Bar
      description: Lorem ipsum...
      documentation_link: https://notion.io/path/to/feature/docs/
      assigned_globs:
        - app/services/bar_stuff/**
        - frontend/javascripts/bar_stuff/**
    CONTENTS

    write_file('app/services/bar_stuff/thing.rb')
    write_file('frontend/javascripts/bar_stuff/thing.jsx')

    write_file('packs/my_other_package/package.yml', <<~CONTENTS)
      enforce_dependency: true
      enforce_privacy: true
      feature: Bar
    CONTENTS

    write_file('package.yml', <<~CONTENTS)
      enforce_dependency: true
      enforce_privacy: true
    CONTENTS

    write_file('packs/my_other_package/my_file.rb')
  end

  let(:create_files_with_defined_classes) do
    write_file('app/my_file.rb', <<~CONTENTS)
      # @feature Foo

      require_relative 'my_error'

      class MyFile
        def self.raise_error
          MyError.raise_error
        end
      end
    CONTENTS

    write_file('app/my_error.rb', <<~CONTENTS)
      # @feature Bar

      class MyError
        def self.raise_error
          raise "some error"
        end
      end
    CONTENTS

    write_file('config/features/foo.yml', <<~CONTENTS)
      name: Foo
    CONTENTS

    write_file('config/features/bar.yml', <<~CONTENTS)
      name: Bar
    CONTENTS

    # Some of the tests use the `SequoiaTree` constant. Since the implementation leverages:
    # `path = Object.const_source_location(klass.to_s)&.first`, we want to make sure that
    # we re-require the constant each time, since `RSpecTempfiles` changes where the file lives with each test
    Object.send(:remove_const, :MyFile) if defined? MyFile # :
    Object.send(:remove_const, :MyError) if defined? MyError # :
    require Pathname.pwd.join('app/my_file')
  end
end
