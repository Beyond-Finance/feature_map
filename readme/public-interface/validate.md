---
title: Public Interface - Validate
---

FeatureMap comes with a validation function to ensure the following things are true:

1. Only one mechanism is defining the feature assignment for a file. That is -- you can't have a file annotation on a file assigned via glob-based assignment. This helps make feature assignment behavior more clear by avoiding concerns about precedence.
1. All features referenced as an assignment for any file is a valid feature (i.e. it's in the list of `CodeFeatures.all`).
1. All files have a feature assigned. You can specify in `unassigned_globs` to represent a TODO list of files to add feature assignments to.
    * Teams using the [CodeOwnership](https://github.com/rubyatscale/code_ownership/tree/main) gem include a `require_assignment_for_teams` key in the `.feature_map/config.yml` file to have this validation to apply a specific list of team. This allows feature assignments to be rolled out in a gradual manner on a team-by-team basis. The `require_assignment_for_teams` configuration should contain a list of team names (i.e. the value from the `name` key in the associated `config/teams/*.yml` file) for the teams whose files will be included in this validation.
1. The `assignments.yml` file is up to date. This is automatically corrected and staged unless specified otherwise with `bin/featuremap validate --skip-autocorrect --skip-stage`. You can turn this validation off by setting `skip_features_validation: true` in `.feature_map/config.yml`.

FeatureMap also allows you to specify which globs and file extensions should be considered assignable.

Here is an example `.feature_map/config.yml`.
```yml
assigned_globs:
  - '{app,components,config,frontend,lib,packs,spec}/**/*.{rb,rake,js,jsx,ts,tsx}'
unassigned_globs:
  - db/**/*
  - app/services/some_file1.rb
  - app/services/some_file2.rb
  - frontend/javascripts/**/__generated__/**/*
```

# Command

You can call the validation function with the Ruby API
```ruby
FeatureMap.validate!
```
or the CLI
```
bin/featuremap validate
```

# Input

This command must be run within a repository that has been configured to use FeatureMap, and where feature assigments have been recorded.  For more, see [Getting Started - Configuration]({{ '/getting-started/configuration' | relative_url }})

# Output

When you run `bin/featuremap validate`, the following files will automatically be generated:

- [`.feature_map/assignments.yml`]({{ '/artifacts/assignments' | relative_url }})
- [`.feature_map/metrics.yml`]({{ '/artifacts/metrics' | relative_url }})
