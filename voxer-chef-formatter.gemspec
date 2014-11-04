# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "voxer-chef-formatter"
  spec.version       = "0.0.1"
  spec.authors       = ["Michael Burns"]
  spec.email         = ["michael.burns@rackspace.com"]
  spec.summary       = %q{Chef Formatter based on Minimal.}
  spec.description   = %q{Improves the output of a chef run with colorized output and better error messages.}
  spec.homepage      = "https://github.com/mburns/voxer-chef-formatter"
  spec.license       = "MIT"

  spec.rubyforge_project = "voxer-chef-formatter"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
