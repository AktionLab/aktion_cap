# -*- encoding: utf-8 -*-
require File.expand_path('../lib/aktion_cap/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chris Boertien"]
  gem.email         = ["chris@aktionlab.com"]
  gem.description   = %q{Contains all require deployment gems, recipes and rake tasks}
  gem.summary       = %q{Deployment gem}
  gem.homepage      = "http://aktionlab.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "aktion_cap"
  gem.require_paths = ["lib"]
  gem.version       = AktionCap::VERSION

  gem.add_dependency 'capistrano', '~> 2.13.4'
  gem.add_dependency 'capistrano-ext', '~> 1.2.1'
  gem.add_dependency 'rvm-capistrano', '~> 1.2.7'
end
