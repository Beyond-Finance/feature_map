RSpec.shared_context 'application fixtures' do
  let(:assignments_file_path) { Pathname.pwd.join('.feature_map/assignments.yml') }

  def write_configuration(assigned_globs: nil, **kwargs)
    assigned_globs ||= ['{app,components,config,frontend,lib,packs,spec}/**/*.{rb,rake,js,jsx,ts,tsx,json,yml}']
    config = {
      'assigned_globs' => assigned_globs,
      'unassigned_globs' => ['.feature_map/config.yml']
    }.merge(kwargs)
    write_file('.feature_map/config.yml', config.to_yaml)
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

    write_file('.feature_map/definitions/bar.yml', <<~CONTENTS)
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
    write_configuration

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

    write_file('.feature_map/definitions/foo.yml', <<~CONTENTS)
      name: Foo
    CONTENTS

    write_file('.feature_map/definitions/bar.yml', <<~CONTENTS)
      name: Bar
    CONTENTS

    # Some of the tests use the `SequoiaTree` constant. Since the implementation leverages:
    # `path = Object.const_source_location(klass.to_s)&.first`, we want to make sure that
    # we re-require the constant each time, since `RSpecTempfiles` changes where the file lives with each test
    Object.send(:remove_const, :MyFile) if defined? MyFile # :
    Object.send(:remove_const, :MyError) if defined? MyError # :
    require Pathname.pwd.join('app/my_file')
  end

  # Only to be used in conjuction with the create_files_with_defined_classes fixture.
  let(:create_files_with_team_assignments) do
    write_file('config/code_ownership.yml', { assigned_globs: ['app/**/*'] }.to_yaml)

    write_file('config/teams/team_a.yml', <<~CONTENTS)
      name: Team A
    CONTENTS

    write_file('config/teams/team_b.yml', <<~CONTENTS)
      name: Team B
    CONTENTS

    write_file('app/foo_stuff_owned_by_team_a.rb', <<~CONTENTS)
      # @team Team A
      # @feature Foo

      class FooStuffOwnedByTeamA
        def self.call
          puts "Doing some Foo related stuff that Team A knows about..."
        end
      end
    CONTENTS

    write_file('app/foo_stuff_owned_by_team_b.rb', <<~CONTENTS)
      # @team Team B
      # @feature Foo

      class FooStuffOwnedByTeamB
        def self.call
          puts "Doing some Foo related stuff that Team B knows about..."
        end
      end
    CONTENTS

    write_file('app/other_team_b_stuff.rb', <<~CONTENTS)
      # @team Team B
      # @feature Bar

      class OtherTeamBStuff
        def self.call
          puts "Doing some other stuff that Team B knows about."
        end
      end
    CONTENTS

    # Some of the tests use the `SequoiaTree` constant. Since the implementation leverages:
    # `path = Object.const_source_location(klass.to_s)&.first`, we want to make sure that
    # we re-require the constant each time, since `RSpecTempfiles` changes where the file lives with each test
    Object.send(:remove_const, :FooStuffOwnedByTeamA) if defined? FooStuffOwnedByTeamA # :
    Object.send(:remove_const, :FooStuffOwnedByTeamB) if defined? FooStuffOwnedByTeamB # :
    Object.send(:remove_const, :OtherTeamBStuff) if defined? OtherTeamBStuff # :
    require Pathname.pwd.join('app/foo_stuff_owned_by_team_a')
    require Pathname.pwd.join('app/foo_stuff_owned_by_team_b')
    require Pathname.pwd.join('app/other_team_b_stuff')
  end

  let(:create_validation_artifacts) do
    create_files_with_defined_classes

    write_file('.feature_map/assignments.yml', <<~CONTENTS)
      ---
      files:
        app/my_error.rb:
          feature: Bar
          mapper: Annotations at the top of file
      features:
        Bar:
          - app/my_error.rb
    CONTENTS
    write_file('.feature_map/metrics.yml', <<~CONTENTS)
      ---
      features:
        Bar:
          abc_size: 12.34
          lines_of_code: 56
          cyclomatic_complexity: 7
    CONTENTS
  end

  let(:create_test_coverage_artifacts) do
    create_files_with_defined_classes

    write_file('.feature_map/test-coverage.yml', <<~CONTENTS)
      ---
      features:
        Bar:
          lines: 56
          hits: 48
          misses: 6
    CONTENTS
  end
end
