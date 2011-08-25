# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tanga_namespaced_helpers/version"

Gem::Specification.new do |s|
  s.name        = "tanga_namespaced_helpers"
  s.version     = TangaNamespacedHelpers::VERSION
  s.authors     = ["Joe Van Dyk"]
  s.email       = ["joe@tanga.com"]
  s.homepage    = ""
  s.summary     = %q{Namespace your Rails helper methods}
  s.description = %q{Namespace your Rails helper methods}

  s.rubyforge_project = "tanga_namespaced_helpers"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
