require 'rubygems'
require 'pangea'
require 'yaml'

config = nil
File.open 'cluster_config.yml' do |f|
  config = YAML.load f
end

cluster = Pangea::Cluster.new(config['cluster_nodes'])

host = cluster.hosts.first
metrics = host.metrics

puts "Metrics for #{host.label}"

# total host memory
# Pange::Util.humanize_bytes translate bytes to MB, GB, TB...
puts Pangea::Util.humanize_bytes( metrics.memory_total )

# free host memory
# Memory Available in the host to be used by the DomUs
puts Pangea::Util.humanize_bytes( metrics.memory_free )
