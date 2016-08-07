# -*- encoding: utf-8 -*-
require File.expand_path('../lib/baton/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["John Griffin", "Carlos Vilhena"]
  gem.email         = ["johnog@gmail.com", "carlosvilhena@gmail.com"]
  gem.description   = "Baton"
  gem.summary       = "Baton"
  gem.homepage      = "https://github.com/digital-science/baton"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n").reject { |fn| fn.include? ".tgz" }
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n").reject { |fn| fn.include? ".tgz" }
  gem.name          = "baton"
  gem.require_paths = ["lib"]
  gem.version       = Baton::VERSION

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_runtime_dependency "amqp", "~> 0.9"
  gem.add_runtime_dependency "amq-client", "~> 0.9"
  gem.add_runtime_dependency "eventmachine", "~> 1.0"
  gem.add_runtime_dependency "em-http-request", "1.0"
  gem.add_runtime_dependency "bunny", "~> 0.8"
  gem.add_runtime_dependency "chef", "~> 11.8"
  gem.add_runtime_dependency "thor", "~> 0.19"

  gem.add_development_dependency "bueller", "~> 0.0"
  gem.add_development_dependency "rspec", "~> 2.7"
  gem.add_development_dependency "moqueue", "~> 0.1"
  gem.add_development_dependency "fakefs", "~> 0.4"
  gem.add_development_dependency "rake", "~> 0.9"
  gem.add_development_dependency "webmock", "~> 1.8"
  gem.add_development_dependency "minitar", "~> 0.5"
  gem.add_development_dependency "simplecov", "~> 0.6"
  gem.add_development_dependency "pry", "~> 0.10"
  gem.add_development_dependency "guard-rspec", "~> 3.0"
end
