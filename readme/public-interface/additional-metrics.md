---
title: Public Interface - Additional Metrics
---

FeatureMap supports the generation of additional metrics derived from comparing an individual feature against features in the same codebase.  These are calculated from base metrics like line count and cyclomatic complexity, as well as other metrics like test coverage.

The additional metrics provide percentile, percent-of-max, and raw score data.  These metrics are also used to express a "health score" calculation based on the featuremap installation's configuration.


# Command

Additional metrics are calculated as part of generating the documentation site.  They can also be calculated independently:

> `bin/featuremap additional_metrics`


# Input

In order for additional metrics to be fully calculated, featuremap's `metrics.yml` and `test-coverage.yml` must be present in the project's `.feature_map` directory.

# Output

This command results in the generation of `.feature_map/additional-metrics.yml`.  More information regarding this artifact can be found at [Artifacts - Additional Metrics]({{ '/artifacts/additional-metrics' | relative_url }}).
