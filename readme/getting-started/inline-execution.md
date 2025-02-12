---
title: Code Ownership
---

FeatureMap is a Ruby gem and must be executed within a Ruby environment.  For non-Ruby projects, this may be done by via [inline bundling](https://bundler.io/guides/bundler_in_a_single_file_ruby_script.html).

An inline-bundled script might look like:

```
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'feature_map'
end

FeatureMap::Cli.run!(ARGV)
```

This can be placed in a script within any project and made executable (`chmod +x`), and invoked as if it were a command-line tool.  Note that some environments are packaged with system libraries (e.g., `uri`) whose version conflicts with the version that FeatureMap expects.  Resolve these issues by installing FeatureMap's version of the given dependency in your system's environment.
