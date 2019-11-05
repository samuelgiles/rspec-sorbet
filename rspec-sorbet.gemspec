lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rspec/sorbet/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-sorbet'
  spec.version       = RSpec::Sorbet::VERSION
  spec.authors       = ['Samuel Giles']
  spec.email         = ['samuel.giles@bellroy.com']

  spec.summary       = 'A small gem consisting of helpers for using Sorbet & RSpec together.'
  spec.homepage      = 'https://github.com/tricycle/rspec-sorbet'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/}) && !f.match(%r{^spec/support/factories/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sorbet'
  spec.add_dependency 'sorbet-runtime'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
