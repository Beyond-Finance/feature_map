Gem::Specification.new do |spec|
  spec.name          = 'feature_map'
  spec.version       = '1.2.7'
  spec.authors       = ['Beyond Finance']
  spec.email         = ['engineering@beyondfinance.com']
  spec.summary       = 'A gem to help identify and manage features within large Ruby and Rails applications'
  spec.description   = 'FeatureMap helps identify and manage features within large Ruby and Rails applications. This gem works best in large, usually monolithic code bases for applications that incorporate a wide range of features with various dependencies.'
  spec.homepage      = 'https://github.com/Beyond-Finance/feature_map'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.6'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/Beyond-Finance/feature_map'
    spec.metadata['changelog_uri'] = 'https://github.com/Beyond-Finance/feature_map/releases'
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end
  # https://guides.rubygems.org/make-your-own-gem/#adding-an-executable
  # and
  # https://bundler.io/blog/2015/03/20/moving-bins-to-exe.html
  spec.executables = ['featuremap']

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['README.md', 'lib/**/*', 'bin/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'code_ownership', '~> 1.34'
  spec.add_dependency 'faraday', '~> 2.7'
  spec.add_dependency 'packs-specification', '~> 0.0'
  spec.add_dependency 'rubocop', '~> 1.0'
  spec.add_dependency 'uri', '~> 1.0'

  spec.add_development_dependency 'debug', '~> 1.9'
  spec.add_development_dependency 'github-pages', '~> 232'
  spec.add_development_dependency 'railties', '~> 7.2'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock', '~> 3.24'
end
