require 'rubygems'
require 'pangea'
require 'yaml'

config = nil
File.open 'cluster_config.yml' do |f|
  config = YAML.load f
end

cluster = Pangea::Cluster.new(config['cluster_nodes'])

cluster.hosts.each do |host|
  puts host
end
