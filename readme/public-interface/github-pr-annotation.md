---
title: Public Interface - GitHub PR Annotation
---

Comments on a pull request with the features its changes affect, and keeps a matching set of feature labels on the pull request. The comment lists the changed files for each feature and a table of how the change moves the feature's metrics (ABC size, lines of code and cyclomatic complexity) compared with the base branch.

This command posts to GitHub. Running it against a real pull request creates or updates its comment and labels.

# Command

> `bin/featuremap github_pr_annotation`

The command takes no arguments. All of its settings come from the `github_pr_annotation` section of `.feature_map/config.yml`. Without that section, the command prints that it is not configured and exits successfully.

# Configuration

```
github_pr_annotation:
  github_token: '<%= ENV.fetch('ACCESS_TOKEN_GITHUB', '') %>'
  pr_number: '<%= ENV.fetch('PR_NUMBER', '') %>'
  base_metrics_path: '<%= ENV.fetch('BASE_METRICS_PATH', '') %>'
```

  - `github_token` (required): a token that can read the pull request and write comments and labels.
  - `pr_number` (required): the pull request to annotate.
  - `base_metrics_path`: the `metrics.yml` generated on the base branch. When the file does not exist, the command prints a message and skips the annotation.

A command with a required key left empty stops with an error naming the key.

The command also needs two top-level keys in `.feature_map/config.yml`, and stops with an error if either is missing:

  - `repository.url`: the repository's GitHub URL, used to find the organization.
  - `documentation_site_url`: the base URL of your documentation site, used for the documentation links in the comment.

See [Getting Started - Configuration]({{ '/getting-started/configuration' | relative_url }}) for how environment variables are read.

# Setting it up

See [Continuous Integration - PR Tags]({{ '/continuous-integration/pr-tags' | relative_url }}) for a GitHub Actions workflow that runs this command.

# Input

Run `validate` on the base branch and keep its `.feature_map/metrics.yml` at the `base_metrics_path`, then run `validate` on the pull request branch before running this command.
