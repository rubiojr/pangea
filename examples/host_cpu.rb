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

puts "Host CPUs"
host.cpus.each do |cpu|
  puts "*** CPU #{cpu.number} ***"
  puts "Speed:       #{cpu.speed}"
  puts "Vendor:      #{cpu.vendor}"
  puts "Model:       #{cpu.model_name}"
  puts "Utilisation: #{cpu.utilisation * 100} %"
end
