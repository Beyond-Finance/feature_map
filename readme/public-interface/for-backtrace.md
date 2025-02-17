---
title: Public Interface - For Backtrace
---

`FeatureMap.for_backtrace` can be given a backtrace and will either return `nil`, or a `CodeFeatures::Feature`.

This will go through the backtrace, and return the feature of the first files with a feature assignment associated with frames within the backtrace.

See `feature_map_spec.rb` for an example.

# Command

```ruby
FeatureMap.for_backtrace(exception.backtrace)
```

_Note_: There is no command line utility for `for_backtrace`; this command is available only within the Ruby runtime.
