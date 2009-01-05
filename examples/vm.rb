require 'rubygems'
require 'pangea'
require 'yaml'

config = nil
File.open 'cluster_config.yml' do |f|
  config = YAML.load f
end

cluster = Pangea::Cluster.new(config['cluster_nodes'])

host = cluster.hosts.first

puts "Listing VMs resident in #{host.label}..."

host.resident_vms.each do |vm|
  # vm label (name listed by 'xm list')
  puts "VM Label: #{vm.label}"
  puts "UUID: #{vm.uuid}"
  puts "Power State #{vm.power_state}"
  # maxmex parameter in domU config file
  puts "Max Mem: #{Pangea::Util.humanize_bytes(vm.max_mem)}"
  # memory parameter in domU config file
  puts "Memory: #{vm.dyn_min_mem}"
  puts
end

