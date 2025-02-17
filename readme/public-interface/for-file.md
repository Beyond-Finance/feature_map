---
title: For File
---

`FeatureMap.for_file`, given a relative path to a file returns a `CodeFeatures::Feature` if there is a feature assigned to the file, `nil` otherwise.

Contributor note: If you are making updates to this method or the methods getting used here, please benchmark the performance of the new implementation against the current for both `for_files` and `for_file` (with 1, 100, 1000 files).

See `feature_map_spec.rb` for examples.

# Command

```ruby
FeatureMap.for_file('path/to/file/relative/to/application/root.rb')
```

_Note_: There is no command line utility for `for_file`; this command is available only within the Ruby runtime.
