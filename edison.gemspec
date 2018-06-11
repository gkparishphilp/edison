$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "edison/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "edison"
  s.version     = Edison::VERSION
  s.authors     = ["Gk Parish-Philp", "Michael Ferguson"]
  s.email       = ["gk@groundswellenterprises.com"]
  s.homepage    = "http://www.groundswellenterprises.com"
  s.summary     = "A testing Solution for Rails."
  s.description = "A testing Solution for Rails."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 5.1.6"
  s.add_dependency "swell_media"
  s.add_dependency "bunyan"
  s.add_dependency "abanalyzer"

  s.add_development_dependency "sqlite3"
end
