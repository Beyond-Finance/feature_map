---
title: Public Interface - Test Coverage
---

When you run `bin/featuremap test_coverage`, the test coverage statistics of the latest commit on the main branch will be pulled from [CodeCov](https://codecov.io/) and collected into a set of per-feature test coverage statistics. This feature level test coverage data is then captured in the `.feature_map/test-coverage.yml` file.

This command requires the following CodeCov account settings to be configured within the `.feature_map/config.yml` file:

```yml
code_cov:
  service: github
  owner: Acme-Org
  repo: sample_app
```

See the [CodeCov API docs](https://docs.codecov.com/reference/repos_retrieve) for more information about the expected values for these configurations.

# Command

> `bin/featuremap test_coverage [optional git SHA]`

Test coverage statistics can be pulled for a specific commit (e.g. the latest commit on a feature branch) by including the full commit SHA as an argument at the end of this CLI command (e.g. `bin/featuremap test_coverage ae80a927654997be4f48d3dbcd1320083cf22eea`). Before running this command please check the [CodeCov dashboard](https://app.codecov.io/) for your application to ensure test coverage statistics have been reported for this commit.

# Input

Running the `bin/featuremap test_coverage` requires an active CodeCov API access token to be specified in the `CODECOV_API_TOKEN` environment variable of your shell session. This token is used to retrieve coverage statistics from the CodeCov account configured in the `.feature_map/config.yml` file.

## Generating a CodeCov API Token
Use the following steps to generate a new CodeCov API token:

1. Log into your [CodeCov account](https://app.codecov.io/)
1. Click the "Settings" menu option in the profile dropdown menu in the top right corner of the screen
    ![CodeCov profile menu with Settings menu highlighted]({{ '/images/codeCov-profileMenu.png' | relative_url }})
1. Click the "Access" menu option from the left-hand navigation menu of the Settings page
    ![CodeCov Settings page navigation bar with Access menu highlighted]({{ '/images/codeCov-settingsMenu.png' | relative_url }})
1. Click the "Generate Token" button in the "API Tokens" section of the page
    ![CodeCov Access page with Generate Token button highlighted]({{ '/images/codeCov-apiTokensTable.png' | relative_url }})
1. Enter a descriptive name for the token (e.g. FeatureMap CLI) and click the "Generate Token" button
    ![CodeCov API token creation modal]({{ '/images/codeCov-createTokenModal.png' | relative_url }})
1. __IMPORTANT__: Copy the access token value presented on the screen and store it in a secure location (e.g. 1Password entry, BitWarden entry, etc)
    ![CodeCov newly created API token modal]({{ '/images/codeCov-newTokenModal.png' | relative_url }})

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

# Output

This command results in the generation of `.feature_map/test-coverage.yml`.  More information regarding this artifact can be found at [Artifacts - Test Coverage]({{ '/artifacts/test-coverage' | relative_url }}).
