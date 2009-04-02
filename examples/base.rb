def ask_host
  host_url = ARGV[0]

  if host_url.nil? or host_url !~ /http:\/\/.*$/
    puts "Usage: #{$0} <xen-api server url>"
    puts
    puts "Example: #{$0} http://xen.example.net:9363"
    exit
  end
  return host_url
end
