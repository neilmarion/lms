$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lms/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lms"
  s.version     = Lms::VERSION
  s.authors     = ["Neil Marion dela Cruz"]
  s.email       = ["nmfdelacruz@gmail.com"]
  s.homepage    = "https://github.com/neilmarion/lms"
  s.summary     = "LMS"
  s.description = "LMS"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.7", ">= 5.0.7.1"
  s.add_development_dependency "pg"
  s.add_dependency 'jquery-rails'
end
