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
metrics = host.metrics

puts "Metrics for #{host.label}"
# Pange::Util.humanize_bytes translate bytes to MB, GB, TB...
puts "Total Memory: #{Pangea::Util.humanize_bytes( metrics.memory_total )}"
puts "Free Memory: #{Pangea::Util.humanize_bytes( metrics.memory_free )}"
