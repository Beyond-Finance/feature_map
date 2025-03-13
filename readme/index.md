---
title: Overview
---
<!-- @feature Documentation Content -->

This gem helps identify and manage features within large applications.  It was built specifically to support monolithic Ruby on Rails codebases, but can be integrated using [Inline Execution]({{ '/getting-started/inline-execution' | relative_url }}) into any environment that supports the following comment styles:
  - `#`
  - `//`
  - `/* single or multline */`
  - `<!-- single or multiline -->`
  - `""" single or multiline"""`
  - `''' single or multiline '''`

Configuring FeatureMap in a new application generally follows these steps:

# 1. Installation
FeatureMap may be installed directly into a Ruby environment or Ruby on Rails application from [RubyGems](https://rubygems.org/gems/feature_map).

\
**Global Installation**
> `gem install feature_map`

**Gemfile**
> `gem 'feature_map'``

**Inline**\
FeatureMap may also be executed without direct installation via [inline bundling](https://bundler.io/guides/bundler_in_a_single_file_ruby_script.html).  For more information see [Inline Execution]({{ '/getting-started/inline-execution' | relative_url }}).

# 2. Configuration
FeatureMap's various configurations expect to be found within a top-level `.feature_map` directory.  Its primary configuration is done via a yml file at `.feature_map/configuration.yml`.  For more information, see [Configuration]({{ '/getting-started/configuration' | relative_url }}).

# 3. Feature Definition
The set of Features that compose the application must be defined in a csv file at `.feature_map/assignments.csv`.  For more information, see [Feature Definition]({{ '/getting-started/feature-definition' | relative_url }}).

# 4. Feature Assignment
Source files within the application must be annotated with their corresponding Feature.  For more information, see [Feature Assignment]({{ '/getting-started/feature-assignment' | relative_url }}).

# 5. Artifact Generation
Once all required source files have been assigned to a corresponding feature, FeatureMap is ready to be used.  You can produce artifacts that support various workflows, from [validating assignment in CI]({{ '/continuous-integration/validation' | relative_url }}), to publishing [release notifications]({{ '/continuous-integration/release-notification' | relative_url }}), or [generating the documentation site]({{ '/documentation-site/overview' | relative_url }}) in order to get a holistic view of the health and composition of your system.

See the [Artifacts - Overview]({{ '/artifacts/overview' | relative_url }}) for more details on the artifacts that drive these processes.
