---
title: For Feature
---

`FeatureMap.for_feature` can be used to generate a feature report for a single feature.
```ruby
FeatureMap.for_feature('Onboarding')
```

You can shovel this into a markdown file for easy viewing using the CLI:
```
bin/feature_map for_feature 'Onboarding' > tmp/onboarding_feature_report.md
```
