---
title: Public Interface - For Class
---

`FeatureMap.for_class` can be given a class and will either return `nil`, or a `CodeFeatures::Feature`.

Under the hood, this finds the file where the class is defined and returns the feature assigned to that file.

See `feature_map_spec.rb` for an example.

# Command

```ruby
FeatureMap.for_class(MyClass)
```

_Note_: There is no command line utility for `for_class`; this command is available only within the Ruby runtime.
