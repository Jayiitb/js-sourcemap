# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sourcemap/version'

Gem::Specification.new do |spec|
  spec.name          = "sourcemap"
  spec.version       = Sourcemap::VERSION
  spec.authors       = ["Jayprakash"]
  spec.email         = ["jayprakashjay91@gmail.com"]
  spec.summary       = %q{sourcemap support for rails}
  spec.description   = %q{JS sourcemap support for rails}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.add_development_dependency 'uglifier', '~> 2.6', '>= 2.6.1'
  spec.add_development_dependency 'json', '~> 0'

  spec.files         = Dir["{app,config,db,lib,tasks,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile"]
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  # spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

