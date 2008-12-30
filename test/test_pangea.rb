require 'lib/pangea.rb'
require 'yaml'

config = nil
File.open 'config.yml' do |f|
  config = YAML.load f
end

hc = Pangea::Cluster.new(config['cluster_nodes'])

hc.hosts.each do |h|
  puts h.name_label
  puts h.name_label
end
