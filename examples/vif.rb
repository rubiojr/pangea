require 'rubygems'
begin
  require '../lib/pangea'
rescue
  require 'pangea'
end
# cmdline helper
require "#{File.join(File.dirname(__FILE__), 'base.rb')}"
# from base.rb
host_url = ask_host

host = Pangea::Host.connect(host_url, 'foo', 'bar')

# skip if only one VM available (Dom0)
if host.resident_vms.size > 1
  vm = host.resident_vms[1]
  puts "VM Label:      #{vm.label}"
  vm.vifs.each do |vif|
    puts "Device:      #{vif.device}"
    puts "MAC Address: " + vif.mac
    metrics = vif.metrics
    puts "Kbs Out:     #{metrics.io_write_kbs}"
    puts "Kbs In:      #{metrics.io_read_kbs}"
    puts "----"
  end
end
