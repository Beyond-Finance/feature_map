---
title: For Backtrace
---

`FeatureMap.for_backtrace` can be given a backtrace and will either return `nil`, or a `CodeFeatures::Feature`.

```ruby
FeatureMap.for_backtrace(exception.backtrace)
```

This will go through the backtrace, and return the feature of the first files with a feature assignment associated with frames within the backtrace.

See `feature_map_spec.rb` for an example.
