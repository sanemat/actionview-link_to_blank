# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action_view/link_to_blank/version'

Gem::Specification.new do |spec|
  spec.name          = "actionview-link_to_blank"
  spec.version       = ActionView::LinkToBlank::VERSION
  spec.authors       = ["sanemat"]
  spec.email         = ["o.gata.ken@gmail.com"]
  spec.description   = %q{Alias link_to with target _blank}
  spec.summary       = %q{Alias link_to with target _blank}
  spec.homepage      = "https://github.com/sanemat/actionview-link_to_blank"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'appraisal'

  spec.add_dependency 'actionpack'
  spec.add_dependency 'activesupport'
end
