require 'rubygems'
begin
  require '../lib/pangea'
rescue
  require 'pangea'
end
require 'yaml'

host = Pangea::Host.connect('http://xen-test.example.net:9363', 'foo', 'bar')

puts "******* HOST DETAILS *******"
# host unique identifier
puts "UUID: #{host.uuid}"
# is the host (dom0) alive?
puts "Alive?: #{host.alive?}"
# get the hostname
puts "Hostname: #{host.label}"
puts "Memory Free: #{host.metrics.memory_free}"
puts "CPUs: #{host.cpus.size}"
puts "Xen Version: #{host.software_version['Xen']}"
puts "Arch: #{host.software_version['machine']}"
puts "Kernel Version: #{host.software_version['release']}"

# list all the domUs
puts "******* RESIDENT VMs *******"
host.resident_vms.each do |vm|
  puts vm.label
end

# list all the networks
puts "******* NETWORKS *******"
host.networks.each do |net|
  puts net.label
end
