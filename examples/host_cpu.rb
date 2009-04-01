require 'rubygems'
begin
  require '../lib/pangea'
rescue
  require 'pangea'
end

host = Pangea::Host.connect('http://xen.example.net:9363','user','password')

puts "Host CPUs"
host.cpus.each do |cpu|
  puts "*** CPU #{cpu.number} ***"
  puts "Speed:       #{cpu.speed}"
  puts "Vendor:      #{cpu.vendor}"
  puts "Model:       #{cpu.model_name}"
  puts "Utilisation: #{cpu.utilisation * 100} %"
end
