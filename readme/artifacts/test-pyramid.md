---
title: Artifacts - Test Pyramid
---
The test pyramid file includes details about the number of unit, integration, and regression tests that are assigned to each feature.

# Generation

The test pyramid file is generated by the [`bin/featuremap test_pyramid`]({{ '/public-interface/test-pyramid' | relative_url }}) command.

# Structure

```
---
features:
  Authentication:
    unit_count: 45,
    unit_pending: 1,
    integration_count: 8,
    integration_pending: 2,
    regression_count: 2,
    regression_pending: 0
  Payment Processing:
    unit_count: 10
    unit_pending: 0
    integration_count: 1
    integration_pending: 0
    regression_count: 0
    regression_pending: 0
```
