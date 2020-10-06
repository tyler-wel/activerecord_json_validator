lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record/json_validator/version"

Gem::Specification.new do |spec|
  spec.name = "activerecord_json_validator"
  spec.version = ActiveRecord::JSONValidator::VERSION
  spec.authors = ["Rémi Prévost", "Tyler Welsh"]
  spec.email = ["rprevost@mirego.com", "tylwelsh@gmail.com"]
  spec.description = "ActiveRecord::JSONValidator fork that a more up to date json schema validatorm, json-schemer"
  spec.summary = spec.description
  spec.homepage = "https://github.com/mirego/activerecord_json_validator"
  spec.license = "BSD 3-Clause"

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "activesupport", ">= 4.2.0", "< 7"
  spec.add_development_dependency "phare"
  spec.add_development_dependency "standard", "~> 0.28"

  spec.add_dependency "json-schema", "~> 2.8"
  spec.add_dependency "activerecord", ">= 4.2.0", "< 7"
end
