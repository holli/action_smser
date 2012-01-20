$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "action_smser/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "action_smser"
  s.version     = ActionSmser::VERSION
  s.authors     = ["Olli Huotari"]
  s.email       = ["olli.huotari@iki.fi"]
  s.homepage    = "https://github.com/holli/action_smser"
  s.summary     = "ActionSmser == SMS && ActionMailer. Simple way to use SMS (Short Message Service) in the same way as ActionMailer. Includes also delivery reports and easy way to add custom gateways (simple http and nexmo by default)."
  s.description = "ActionSmser == SMS && ActionMailer. Simple way to use SMS (Short Message Service) in the same way as ActionMailer. Includes also delivery reports and easy way to add custom gateways (simple http and nexmo by default)."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1"

  s.add_development_dependency "mocha"
  #s.add_development_dependency "ruby-debug"
  #s.add_development_dependency "fakeweb"

  s.add_development_dependency "sqlite3"
end
