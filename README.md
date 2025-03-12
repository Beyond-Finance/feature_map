# FeatureMap

This gem helps identify and manage features within large applications.

For usage documentation, please see the [README Site](https://beyond-finance.github.io/feature_map).

## Installation

FeatureMap may be installed directly into a Ruby environment or Ruby on Rails application from [RubyGems](https://rubygems.org/gems/feature_map).

\
**Global Installation**
> `gem install feature_map`

**Gemfile**
> `gem 'feature_map', '~> 1.2'``

**Inline**\
FeatureMap may also be executed without direct installation via [inline bundling](https://bundler.io/guides/bundler_in_a_single_file_ruby_script.html).  For more information see [Inline Execution]({{ '/getting-started/inline-execution' | relative_url }}).

## FeatureMap Gem Structure

Check out [`lib/feature_map.rb`](https://github.com/Beyond-Finance/feature_map/blob/main/lib/feature_map.rb) to see the public API.

Check out [`feature_map_spec.rb`](https://github.com/Beyond-Finance/feature_map/blob/main/spec/lib/feature_map_spec.rb) to see examples of how the feature map utility is used.

## Development

### Ruby Gem
Contributions are welcome and appreciated. Here's how to get started:

- clone repo: `$ git clone git@github.com:Beyond-Finance/feature_map.git`
- install dependencies: `$ bundle install`
- run tests: `$ bundle exec rspec`
- run Rubocop: `$ bundle exec rubocop`

That's it! Assuming you can complete all of these steps without any error or issues, you should be good to go.

### Documentation Site

The documentation site is a React application which is built on the Vite framework.  There are two steps to building the site:  first, the skeleton of the site is compiled and committed into this repository; second, the various artifacts are injected from a host repository into a project-specific instance of the site via [bin/featuremap docs](https://beyond-finance.github.io/feature_map/public-interface/docs).

Compilation of the build asset is done via `npm run build` from within the [docs](./docs) folder.  This compiles the React app into a single static file which is placed in [./lib/feature_map/private/docs/index.html](./lib/feature_map/private/docs/index.html]).

The documentation site may be run locally to aid in development via `bin/docs`.  It will generate test coverage and metrics data, and make it available to the docs site running in development mode.

More information on the development of the documentation site may be found in the [Docs Readme](./docs/README.md).

### README Site

The README site is built with Jekyll and TailwindCSS and is hosted via GitHub Pages at:  https://beyond-finance.github.io/feature_map.  It can be run locally to aid in development via `bin/readme`.

### Publication

When a new version of the gem is ready to be published, please follow these steps:

* Update `spec.version` value in the [feature_map.gemspec](feature_map.gemspec) file.
    * Assign a version to this release in accordance with [Semantic Versioning](https://semver.org/) based on the changes contained in this release.
* Create a new release tag in Github ([link](https://github.com/Beyond-Finance/feature_map/releases)) with a value that matches the new Gemspec version.
* Checkout the release tag in your local environment.
* Publish the new version of the gem to RubyGems ([docs](https://guides.rubygems.org/publishing/#publishing-to-rubygemsorg)), which largely consists of running the following commands:
   * Build a new version of the gem: `gem build feature_map.gemspec`
   * Authenticate with rubygems.org: `gem signin`
   * Publish the new version of the gem: `gem push feature_map-[NEW_VERSION].gem`

## Colophon

The structure and execution of FeatureMap's initial version was based on the gem [CodeOwnership](https://github.com/rubyatscale/code_ownership).

The structure and styling of the README site was based on a theme from [Spinal](https://spinalcms.com/resources/documentation-theme-built-with-tailwind-css/).
