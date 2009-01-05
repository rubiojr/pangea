require 'rubygems'
require 'pangea'
require 'yaml'

config = nil
File.open 'cluster_config.yml' do |f|
  config = YAML.load f
end

#
# Connect to the cluster
#
cluster = Pangea::Cluster.new(config['cluster_nodes'])

cluster.hosts.each do |host|
  puts "******************"
  puts host.label
  puts "******************"

  puts "Number of CPUs: #{host.cpus.size}"
  puts

  puts "Host Metrics"
  puts "------------"
  puts host.metrics
  puts

  puts "Resident VMs"
  puts "------------"
  host.resident_vms.each do |vm|
    puts " #{vm.label} [#{vm.uuid}]"
  end
end
