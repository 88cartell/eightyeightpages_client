# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "eightyeightpages_client/version"

Gem::Specification.new do |s|
  s.name        = "eightyeightpages_client"
  s.version     = EightyeightpagesClient::VERSION
  s.authors     = ["Carl Woodward"]
  s.email       = ["carl@88cartell.com"]
  s.homepage    = "http://88pages.com"
  s.summary     = %q{A simple client for 88pages.com}
  s.description = %q{Ruby implementation of client for CMS as a service app 88pages.com}

  s.rubyforge_project = "eightyeightpages_client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "ruby-debug19"
  s.add_runtime_dependency "httparty"
end
