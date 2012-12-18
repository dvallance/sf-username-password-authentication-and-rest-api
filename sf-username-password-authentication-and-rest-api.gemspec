# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salesforce-api/version'

Gem::Specification.new do |gem|
  gem.name          = "sf-username-password-authentication-and-rest-api"
  gem.version       = SalesforceAPI::VERSION
  gem.authors       = ["David Vallance"]
  gem.email         = ["dvallance@infotech.com\n"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency("activesupport")
end
