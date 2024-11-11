# FeatureMap

This gem helps identify and manage features within large Ruby and Rails applications. This gem works best in large, usually monolithic code bases for applications that incorporate a wide range of features with various dependencies.

Check out [`lib/feature_map.rb`](https://github.com/Beyond-Finance/feature_map/blob/main/lib/feature_map.rb) to see the public API.

Check out [`feature_map_spec.rb`](https://github.com/Beyond-Finance/feature_map/blob/main/spec/lib/feature_map_spec.rb) to see examples of how the feature map utility is used.

## Getting started

To get started there's a few things you should do.

1) Create a `config/feature_map.yml` file and declare where your files live. Here's a sample to start with:
```yml
assigned_globs:
  - '{app,components,config,frontend,lib,packs,spec}/**/*.{rb,rake,js,jsx,ts,tsx}'
unassigned_globs:
  - db/**/*
  - app/services/some_file1.rb
  - app/services/some_file2.rb
  - frontend/javascripts/**/__generated__/**/*
```
2) Declare some features. Here's an example, that would live at `config/features/onboarding.yml`:
```yml
name: Onboarding
description: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation.
documentation_link: https://www.notion.so/onboarding-feature-abcd1234
```
3) Declare feature assignments. You can do this at a directory level or at a file level. All of the files within the `assigned_globs` you declared in step 1 will need to have a feature assigned (or be opted out via `unassigned_globs`). See the next section for more detail.
4) Run validations when you commit, and/or in CI. If you run validations in CI, ensure that if your `FEATURES.yml` file gets changed, that gets pushed to the PR.

## Usage: Assigning Features

There are three ways to assign the feature for a source file using this gem.

### Directory-Based Assignment
Directory based assignment allows for all files in that directory and all its sub-directories to be assigned to a single feature. To define this, add a `.feature` file inside that directory with the name of the feature as the contents of that file.
```
Feature
```

### File-Annotation Based Assignment
File annotations are a last resort if there is no clear home for your code. File annotations go at the top of your file, and look like this:
```ruby
# @feature Onboarding
```

### Glob-Based Assignment
In the YML configuration of a feature, you can set `assigned_globs` to be a glob of files assigned to this feature. For example, in `onboarding.yml`:
```yml
name: Onboarding
assigned_globs:
  - app/services/stuff_for_onboarding/**/**
  - app/controllers/other_stuff_for_onboarding/**/**
```

### Custom Assignment
To enable custom assignment, you can inject your own custom classes into `feature_map`.
To do this, first create a class that adheres to the `FeatureMap::Mapper` and/or `FeatureMap::Validator` interface.
Then, in `config/feature_map.yml`, you can require that file:
```yml
require:
  - ./lib/my_extension.rb
```

Now, `bin/featuremap validate` will automatically include your new mapper and/or validator. See [`spec/lib/feature_map/private/extension_loader_spec.rb](spec/lib/feature_map/private/extension_loader_spec.rb) for an example of what this looks like.

## Usage: Reading FeatureMap
### `for_file`
`FeatureMap.for_file`, given a relative path to a file returns a `CodeFeatures::Feature` if there is a feature assigned to the file, `nil` otherwise.

```ruby
FeatureMap.for_file('path/to/file/relative/to/application/root.rb')
```

Contributor note: If you are making updates to this method or the methods getting used here, please benchmark the performance of the new implementation against the current for both `for_files` and `for_file` (with 1, 100, 1000 files).

See `feature_map_spec.rb` for examples.

### `for_backtrace`
`FeatureMap.for_backtrace` can be given a backtrace and will either return `nil`, or a `CodeFeatures::Feature`.

```ruby
FeatureMap.for_backtrace(exception.backtrace)
```

This will go through the backtrace, and return the feature of the first files with a feature assignment associated with frames within the backtrace.

See `feature_map_spec.rb` for an example.

### `for_class`

`FeatureMap.for_class` can be given a class and will either return `nil`, or a `CodeFeatures::Feature`.

```ruby
FeatureMap.for_class(MyClass)
```

Under the hood, this finds the file where the class is defined and returns the featuer assigned to that file.

See `feature_map_spec.rb` for an example.

### `for_feature`
`FeatureMap.for_feature` can be used to generate a feature report for a single feature.
```ruby
FeatureMap.for_feature('Onboarding')
```

You can shovel this into a markdown file for easy viewing using the CLI:
```
bin/feature_map for_feature 'Onboarding' > tmp/onboarding_feature_report.md
```

## Usage: Generating a `FEATURES.yml` file

A `FEATURES.yml` file captures a mapping of files within a repository to their corresponding feature and a mapping of features to their corresponding files. When you run `bin/featuremap validate`, a `FEATURES.ymle` file will automatically be generated and updated.

## Proper Configuration & Validation

FeatureMap comes with a validation function to ensure the following things are true:

1) Only one mechanism is defining the feature assignment for a file. That is -- you can't have a file annotation on a file assigned via glob-based assignment. This helps make feature assignment behavior more clear by avoiding concerns about precedence.
2) All features referenced as an assignment for any file is a valid feature (i.e. it's in the list of `CodeFeatures.all`).
3) All files have a feature assigned. You can specify in `unassigned_globs` to represent a TODO list of files to add feature assignments to.
  * Teams using the [CodeOwnership](https://github.com/rubyatscale/code_ownership/tree/main) gem include a `require_assignment_for_teams` key in the `feature_map.yml` file to have this validation to apply a specific list of team. This allows feature assignments to be rolled out in a gradual manner on a team-by-team basis. The `require_assignment_for_teams` configuration should contain a list of team names (i.e. the value from the `name` key in the associated `config/teams/*.yml` file) for the teams whose files will be included in this validation.
3) The `FEATURES.yml` file is up to date. This is automatically corrected and staged unless specified otherwise with `bin/featuremap validate --skip-autocorrect --skip-stage`. You can turn this validation off by setting `skip_features_validation: true` in `config/feature_map.yml`.

FeatureMap also allows you to specify which globs and file extensions should be considered assignable.

Here is an example `config/feature_map.yml`.
```yml
assigned_globs:
  - '{app,components,config,frontend,lib,packs,spec}/**/*.{rb,rake,js,jsx,ts,tsx}'
unassigned_globs:
  - db/**/*
  - app/services/some_file1.rb
  - app/services/some_file2.rb
  - frontend/javascripts/**/__generated__/**/*
```
You can call the validation function with the Ruby API
```ruby
FeatureMap.validate!
```
or the CLI
```
bin/featruemap validate
```

## Development

Please add to `CHANGELOG.md` and this `README.md` when you make make changes.
