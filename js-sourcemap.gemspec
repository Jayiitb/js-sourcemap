# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'js-sourcemap/version'

Gem::Specification.new do |spec|
  spec.name          = "js-sourcemap"
  spec.version       = JsSourcemap::VERSION
  spec.authors       = ["Jayprakash"]
  spec.email         = ["jayprakashjay91@gmail.com"]
  spec.summary       = %q{js-sourcemap support for rails}
  spec.description   = %q{JS js-sourcemap support for rails}
  spec.homepage      = "https://github.com/Jayiitb/js-sourcemap"
  spec.license       = "MIT"

  spec.add_development_dependency 'uglifier', '~> 2.6', '>= 2.6.1'

  spec.files         = Dir["{app,config,db,lib,tasks,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile"]
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  # spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

