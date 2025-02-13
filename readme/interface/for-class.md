---
title: For Class
---

`FeatureMap.for_class` can be given a class and will either return `nil`, or a `CodeFeatures::Feature`.

```ruby
FeatureMap.for_class(MyClass)
```

Under the hood, this finds the file where the class is defined and returns the featuer assigned to that file.

See `feature_map_spec.rb` for an example.
