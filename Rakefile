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

task :publish_gem do
  `scp pkg/*.gem xen-fu.org:~/gems.xen-fu.org/gems/`
  `ssh xen-fu.org gem generate_index -d /home/rubiojr/gems.xen-fu.org/`
end
task :upload_docs do
  `rsync --delete -rtlz doc/ xen-fu.org:~/xen-fu.org/pangea/doc/`
end
task :upload_edge_docs do
  `rsync --delete -rtlz doc/ xen-fu.org:~/xen-fu.org/pangea-edge/doc/`
end
