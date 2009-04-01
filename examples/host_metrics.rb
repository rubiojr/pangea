require 'rubygems'
begin
  require '../lib/pangea'
rescue
  require 'pangea'
end

host = Pangea::Host.connect('http://xen.example.net:9363','user','password')
metrics = host.metrics

puts "Metrics for #{host.label}"
# Pange::Util.humanize_bytes translate bytes to MB, GB, TB...
puts "Total Memory: #{Pangea::Util.humanize_bytes( metrics.memory_total )}"
puts "Free Memory: #{Pangea::Util.humanize_bytes( metrics.memory_free )}"
