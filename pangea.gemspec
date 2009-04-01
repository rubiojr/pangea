Gem::Specification.new do |s|
  s.name = %q{pangea}
  s.version = "0.1.20090401135815"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sergio RubioSergio Rubio"]
  s.date = %q{2009-04-01}
  s.default_executable = %q{pangea}
  s.description = %q{Xen-API Ruby Implementation}
  s.email = %q{sergio@rubio.namesergio@rubio.name}
  s.executables = ["pangea"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/pangea", "lib/pangea.rb", "lib/pangea/objects.rb", "lib/pangea/exceptions.rb", "lib/memoizers/simple_memoizer.rb", "lib/memoizers/strategy.rb", "lib/memoizers/timed_memoizer.rb", "lib/util/string.rb", "test/test_pangea.rb", "test/test_cluster.rb", "test/test_network.rb", "test/test_vif.rb", "test/test_vif_metrics.rb", "test/test_vm.rb", "test/test_vm_metrics.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/rubiojr/pangea}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pangea}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby Xen API}
  s.test_files = ["test/test_cluster.rb", "test/test_network.rb", "test/test_pangea.rb", "test/test_vif.rb", "test/test_vif_metrics.rb", "test/test_vm.rb", "test/test_vm_metrics.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 1.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.12.1"])
    else
      s.add_dependency(%q<term-ansicolor>, [">= 1.0"])
      s.add_dependency(%q<hoe>, [">= 1.12.1"])
    end
  else
    s.add_dependency(%q<term-ansicolor>, [">= 1.0"])
    s.add_dependency(%q<hoe>, [">= 1.12.1"])
  end
end
