require 'rake'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'pangea'
require 'hoe'

Hoe.new('Pangea', Pangea::VERSION) do |p|
  p.name = "pangea"
  p.author = "Sergio Rubio"
  p.description = %q{Xen-API Ruby Implementation}
  p.email = 'sergio@rubio.name'
  p.summary = "Ruby Xen API"
  p.url = "http://github.com/rubiojr/pangea"
  #p.clean_globs = ['test/output/*.png']
  #p.changes = p.paragraphs_of('CHANGELOG', 0..1).join("\n\n")
  p.remote_rdoc_dir = '' # Release to root
  p.extra_deps << [ "term-ansicolor",">= 1.0" ]
  p.developer('Sergio Rubio', 'sergio@rubio.name')
end

