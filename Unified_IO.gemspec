# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "Unified_IO/version"

Gem::Specification.new do |s|
  s.name        = "Unified_IO"
  s.version     = Unified_IO::VERSION
  s.authors     = ["da99"]
  s.email       = ["i-hate-spam-45671204@mailinator.com"]
  s.homepage    = ""
  s.summary     = %q{Local and remote io.}
  s.description = %q{
    Access locally and remotely: files, dirs, and shells.
  }

  s.rubyforge_project = "Unified_IO"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency 'bacon'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'Bacon_Colored'
  s.add_development_dependency 'mocha-on-bacon'
  
  s.add_runtime_dependency 'Checked'
  s.add_runtime_dependency 'net-ssh'
  s.add_runtime_dependency 'net-scp'
  s.add_runtime_dependency 'term-ansicolor'
end
