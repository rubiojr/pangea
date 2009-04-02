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

host.resident_vms.each do |vm|
  puts "**** VM #{vm.label} ****"
  puts "On Crash:            #{vm.actions_after_crash}"
  puts "On Reboot:           #{vm.actions_after_reboot}"
  puts "Domain ID:           #{vm.domid}"
  puts "Current Memory:      #{vm.dyn_min_mem}"
  puts "Max Memory:          #{vm.dyn_max_mem}"
  puts "Power State:         #{vm.power_state}"
  puts "Virtual Interfaces:  #{vm.vifs.size}"
  puts "Host:       #{vm.resident_on.label}"
  puts
end
