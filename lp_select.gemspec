# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lp_select/version'

Gem::Specification.new do |spec|
  spec.name          = "lp_select"
  spec.version       = LpSelect::VERSION
  spec.authors       = ["Jake Sower", "James Prior"]
  spec.email         = ["j.sower@asee.org", "j.prior@asee.org"]
  spec.description   = %q{Ruby bindings for LPSolve}
  spec.summary       = %q{Ruby bindings for LPSolve}
  spec.homepage      = ""
  spec.license       = "LGPL"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "ffi"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
