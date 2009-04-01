require 'rubygems'
begin
  require '../lib/pangea'
rescue
  require 'pangea'
end

host = Pangea::Host.connect('http://xen9.gestion.privada.csic.es:9363', 'foo', 'bar')

puts "Listing VMs resident in #{host.label}..."

host.resident_vms.each do |vm|
  # vm label (name listed by 'xm list')
  puts "VM Label:       #{vm.label}"
  puts "UUID:           #{vm.uuid}"
  puts "Power State:    #{vm.power_state}"
  # maxmex parameter in domU config file
  puts "Max Mem:        #{Pangea::Util.humanize_bytes(vm.max_mem)}"
  # memory parameter in domU config file
  puts "Memory:         #{vm.dyn_min_mem}"
  # host hosting the vm
  puts "Resident On:    #{vm.resident_on.label}"
  puts "Dom ID:         #{vm.domid}"
  puts "Is dom0?:       #{vm.is_control_domain?}"
  puts "Kernel:         #{vm.pv_kernel}"
  puts "Number of VIFs: #{vm.vifs.size}"
  puts "--------"
end

