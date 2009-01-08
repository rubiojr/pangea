require 'lib/pangea.rb'
require 'yaml'

config = nil
File.open 'config.yml' do |f|
  config = YAML.load f
end

hc = Pangea::Cluster.new(config['cluster_nodes'])

hc.hosts[0].cpus.each do |hcpu|
  puts hcpu.number
  puts hcpu.vendor
  puts hcpu.speed
  puts hcpu.model_name
end
#puts hc.hosts[0].sched_policy
#puts hc.hosts[0].software_version['Xen']
#hc.hosts[0].resident_vms.each do |rvm|
#  puts
#  puts rvm.inspect
#  puts rvm.metrics.inspect
#end
