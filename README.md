# FeatureMap


## FeatureMap Gem Structure

Check out [`lib/feature_map.rb`](https://github.com/Beyond-Finance/feature_map/blob/main/lib/feature_map.rb) to see the public API.

Check out [`feature_map_spec.rb`](https://github.com/Beyond-Finance/feature_map/blob/main/spec/lib/feature_map_spec.rb) to see examples of how the feature map utility is used.


## Usage: Generating Feature Assignment files

When you run `bin/featuremap validate`, the following files will automatically be generated:
 * `.feature_map/assignments.yml`: Captures a mapping of files within a repository to their corresponding feature and a mapping of features to their corresponding files.
 * `.feature_map/metrics.yml`: Captures a set of metrics rolled up at the feature level (i.e. computed over all files assigned to the feature).

## Usage: Generating Documentation



## Usage: Generating the Test Pyramid

The feature map gem supports reporting on the [test pyramid](https://martinfowler.com/bliki/TestPyramid.html) coverage of the application and its constituent features.  It works, broadly, by:  accepting test execution reports (e.g., rspec's `json` format) for unit, integration, and regression tests -- and then matches those tests to their corresponding features as follows:
  - Unit:  Uses tech stack conventions, e.g., rspec tests in `spec/models/user_spec.rb` are resolved to the `app/models/user.rb` implementation file, which may be matched with its feature annotation.
  - Integration:  Integration tests do not correspond to a single implementation file (though generally live within the same codebase), so they must be directly annotated with the feature they support.
  - Regression:  Regression tests do not correspond to a single implementation file, and may live in a given codebase or in a separate repository.  They must both be tagged with the feature that they support, and a reference to the assignments of regression tests must be passed to the test pyramid generation command.

Once test pyramid data has been generated for a give project, it's automatically included in that project's doc site.

To generate the test pyramid data, run:
> bin/featuremap test_pyramid [unit_examples_file] [integration_examples_file] [regression_examples_file] [regression_assignments_file]

Note:  FeatureMap currently only supports _examples files_ in rspec's `json` format (--format json), though support for others (e.g., jest's `--json`, or the JUnit XML format) may be added in the future.

## Usage: Collecting Test Coverage

When you run `bin/featuremap test_coverage`, the test coverage statistics the latest commit on the main branch will be pulled from [CodeCov](https://codecov.io/) and collected into a set of per-feature test coverage statistics. This feature level test coverage data is then captured in the `.feature_map/test-coverage.yml` file.

This command requires the following CodeCov account settings to be configured within the `.feature_map/config.yml` file:

```yml
code_cov:
  service: github
  owner: Acme-Org
  repo: sample_app
```

See the [CodeCov API docs](https://docs.codecov.com/reference/repos_retrieve) for more information about the expected values for these configurations.

Test coverage statistics can be pulled for a specific commit (e.g. the latest commit on a feature branch) by including the full commit SHA as an argument at the end of this CLI command (e.g. `bin/featuremap test_coverage ae80a927654997be4f48d3dbcd1320083cf22eea`). Before running this command please check the [CodeCov dashboard](https://app.codecov.io/) for your application to ensure test coverage statistics have been reported for this commit.

### CodeCov API Token Generation

Running the `bin/featuremap test_coverage` requires an active CodeCov API access token to be specified in the `CODECOV_API_TOKEN` environment variable of your shell session. This token is used to retrieve coverage statistics from the CodeCov account configured in the `.feature_map/config.yml` file.

Use the following steps to generate a new CodeCov API token:

1. Log into your [CodeCov account](https://app.codecov.io/)
1. Click the "Settings" menu option in the profile dropdown menu in the top right corner of the screen
    ![CodeCov profile menu with Settings menu highlighted](readme_assets/codeCov-profileMenu.png)
1. Click the "Access" menu option from the left-hand navigation menu of the Settings page
    ![CodeCov Settings page navigation bar with Access menu highlighted](readme_assets/codeCov-settingsMenu.png)
1. Click the "Generate Token" button in the "API Tokens" section of the page
    ![CodeCov Access page with Generate Token button highlighted](readme_assets/codeCov-apiTokensTable.png)
1. Enter a descriptive name for the token (e.g. FeatureMap CLI) and click the "Generate Token" button
    ![CodeCov API token creation modal](readme_assets/codeCov-createTokenModal.png)
1. __IMPORTANT__: Copy the access token value presented on the screen and store it in a secure location (e.g. 1Password entry, BitWarden entry, etc)
    ![CodeCov newly created API token modal](readme_assets/codeCov-newTokenModal.png)

#### __OPTIONAL__:  Store the token as an environment variable in your shell's environment:
**ZSH**
  ```shell
  echo 'export CODECOV_API_TOKEN="YOUR_CODECOV_API_TOKEN"' >> ~/.zshrc
  source ~/.zshrc
  ```

**Bash**
  ```shell
  echo 'export CODECOV_API_TOKEN="YOUR_CODECOV_API_TOKEN"' >> ~/.bashrc
  source ~/.bashrc
  ```

## Proper Configuration & Validation

FeatureMap comes with a validation function to ensure the following things are true:

1) Only one mechanism is defining the feature assignment for a file. That is -- you can't have a file annotation on a file assigned via glob-based assignment. This helps make feature assignment behavior more clear by avoiding concerns about precedence.
2) All features referenced as an assignment for any file is a valid feature (i.e. it's in the list of `CodeFeatures.all`).
3) All files have a feature assigned. You can specify in `unassigned_globs` to represent a TODO list of files to add feature assignments to.
    * Teams using the [CodeOwnership](https://github.com/rubyatscale/code_ownership/tree/main) gem include a `require_assignment_for_teams` key in the `.feature_map/config.yml` file to have this validation to apply a specific list of team. This allows feature assignments to be rolled out in a gradual manner on a team-by-team basis. The `require_assignment_for_teams` configuration should contain a list of team names (i.e. the value from the `name` key in the associated `config/teams/*.yml` file) for the teams whose files will be included in this validation.
3) The `assignments.yml` file is up to date. This is automatically corrected and staged unless specified otherwise with `bin/featuremap validate --skip-autocorrect --skip-stage`. You can turn this validation off by setting `skip_features_validation: true` in `.feature_map/config.yml`.

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
You can call the validation function with the Ruby API
```ruby
FeatureMap.validate!
```
or the CLI
```
bin/featuremap validate
```

## Development

Contributions are welcome and appreciated. Here's how to get started:

- clone repo: `$ git clone git@github.com:Beyond-Finance/feature_map.git`
- install dependencies: `$ bundle install`
- run tests: `$ bundle exec rspec`
- run Rubocop: `$ bundle exec rubocop`
- run Sorbet: `$ bundle exec srb tc`

That's it! Assuming you can complete all of these steps without any error or issues, you should be good to go.

#### Publication

When a new version of the gem is ready to be published, please follow these steps:

* Update `spec.version` value in the [feature_map.gemspec](feature_map.gemspec) file.
    * Assign a version to this release in accordance with [Semantic Versioning](https://semver.org/) based on the changes contained in this release.
* Create a new release tag in Github ([link](https://github.com/Beyond-Finance/feature_map/releases)) with a value that matches the new Gemspec version.
* Checkout the release tag in your local environment.
* Publish the new version of the gem to RubyGems ([docs](https://guides.rubygems.org/publishing/#publishing-to-rubygemsorg)), which largely consists of running the following commands:
   * Build a new version of the gem: `gem build feature_map.gemspec`
   * Authenticate with rubygems.org: `gem signin`
   * Publish the new version of the gem: `gem push feature_map-[NEW_VERSION].gem`
