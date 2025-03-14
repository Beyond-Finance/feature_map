---
title: Getting Started - Configuration
---

FeatureMap is configured via its `.feature_map/config.yml` configuration file.  Directives are described inline, below.  Feel free to copy and paste this into your project as a starting point.

```
# An array of file globs where FeatureMap expects to find annotations
assigned_globs:
  - app/**/*.rb

# An array of file globs that do not require annotations
# even if they're within assigned_globs, below.
# May be an empty array
unassigned_globs:
  - app/models/**/*
  - app/controllers/admin/**/*

# Enables the identification of teams responsible for each feature based
# on the CodeOwnership team assigned to the files for a feature (see
# https://github.com/rubyatscale/code_ownership for more detail).
skip_code_ownership: false

# Allows the validation check to ignore files assigned to teams other than
# those specified here. Must be null when skipping code ownership.
require_assignment_for_teams:
  - Onboarding

# Disables the requirement for the assignments.yml file to be up to date and
# committed to the codebase
skip_features_validation: false

# Supports the retrieval of rolled up test coverage
# statistics from CodeCov.  Used by the `test_coverage` CLI
# command.
code_cov:
  service: github
  owner: Example
  repo: example

# GitHub repository information.  Required for various interactions
# with git (commit history, file reference links to source in GitHub).
repository:
  main_branch: 'main'
  url: https://example.com

# This is the URL of your hosted feature map documentation (which is generated by bin/featuremap docs)
# It supports link generation in message construction, e.g., release announcements
documentation_site_url: example.github.io/doc-site-hosted-in-gh-pages

# Various configurations used by the documentation site.
documentation_site:
  health:
    minimum_thresholds:
      good: 95
      fair: 80
      poor: 0
    components:
      cyclomatic_complexity:
        # The relative proportion of total health score that this component adds
        weight: 5
        # A threshold measured against the maximum scoring feature, after which
        # a given feature should receive a perfect score.  For percentile-based
        # health components, this allows features to score well when their
        # specific score may be in a lower percentile (e.g., a score of 9.6 in the set of scores [9.6, 9.7, 9.8, 9.9])
        # but which is still very close to the top score.
        percent_of_max_threshold: 90
      encapsulation:
        weight: 10
        percent_of_max_threshold: 90
      test_coverage:
        weight: 70
        # In absolute scoring components, like test coverage, this number is an
        # absolute threshold after which a feature receives a perfect score.
        percent_of_max_threshold: 95
      todo_count:
        weight: 15
        percent_of_max_threshold: 95
  linked_sites:
    - name: User Service
      url: https://example.github.io/user-service
    - name: Gateway Service
      url: https://example.github.io/gateway-service
  size_percentile:
    minimum_thresholds:
      xl: 95
      l: 75
      m: 25
      s: 5
      xs: 0
  title: Example Site
  test_coverage:
    minimum_thresholds:
      good: 98
      fair: 95
      poor: 0
```
