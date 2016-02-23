# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bq_factory/version'

Gem::Specification.new do |spec|
  spec.name          = "bq_factory"
  spec.version       = BqFactory::VERSION
  spec.authors       = ["yuemori"]
  spec.email         = ["yuemori@aiming-inc.com"]

  spec.summary       = %q{Create BigQuery view from hash}
  spec.description   = %q{Create BigQuery view from hash}
  spec.homepage      = "http://github.com/yuemori/bq_factory"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "gcloud", "~> 0.6.1"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov", "~> 0.8.0"
end
