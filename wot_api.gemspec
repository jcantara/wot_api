# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wot_api/version'

Gem::Specification.new do |spec|
  spec.name          = "wot_api"
  spec.version       = WotApi::VERSION
  spec.authors       = ["Jesse Cantara"]
  spec.email         = ["jcantara@gmail.com"]
  spec.summary       = %q{API wrapper for 'World of Tanks'.}
  spec.description   = %q{API wrapper for the game 'World of Tanks'; including User Accounts, and Clans, but not OpenID Authentication.}
  spec.homepage      = "https://github.com/jcantara/wot_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakeweb"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "simplecov"

  spec.add_runtime_dependency "httparty"

  spec.requirements << "Application ID(s) from Wargaming developers portal."

  spec.required_ruby_version = '>= 1.9.3'
end
