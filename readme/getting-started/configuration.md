---
title: Configuration
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

# Enables the identification of teams responsible
# for each feature based on team assignments.
skip_code_ownership: false

# Expects feature annotations only for files owned
# by the given teams unless disabled (of the assigned_globs, above).
# Must be null when skipping code ownership.
require_assignment_for_teams:
  - Onboarding

# Skips validation of the associated assignments file
skip_features_validation: false

# Supports the retrieval of rolled up test coverage
# statistics from CodeCov.  Used by the `test_coverage` CLI
# command.
code_cov:
  service: github
  owner: Example
  repo: example

# GitHub repository information.  Required for various interactions
# with git (commit history, links file references to source in GitHub).
repository:
  main_branch: 'main'
  url: https://example.com

# Various configurations used by the documentation site.
documentation_site:
  health:
    minimum_thresholds:
      good: 95
      fair: 80
      poor: 0
    components:
      cyclomatic_complexity:
        weight: 15
        minimum_variance: 10
        score_threshold: 100
      encapsulation:
        weight: 15
        minimum_variance: 10
        score_threshold: 100
      test_coverage:
        weight: 70
        score_threshold: 98
  size_percentile:
    minimum_thresholds:
      xl: 95
      l: 75
      m: 25
      s: 5
      xs: 0
  test_coverage:
    minimum_thresholds:
      good: 98
      fair: 95
      poor: 0
```
