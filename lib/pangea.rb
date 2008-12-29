require 'xmlrpc/client'
require 'pp'

module Pangea

  VERSION = '0.0.1'

  class Cluster
    def initialize(hosts={})
      @links = []
      hosts.each_key do |n|
        @links << Link.new(hosts[n]['url'], 
                                  hosts[n]['username'] || '', 
                                  hosts[n]['passwor'] || ''
                                  ) 
      end
    end

    def hosts
      list = []
      @links.each do |hl|
        ref = hl.client.call('host.get_all', hl.sid)['Value'][0]
        h = Host.new(hl, ref, hl.client.proxy('host'))
        list << h
      end
      list
    end
  end

  class Link

    attr_reader :client, :session, :sid

    def initialize(url, username='foo', password='bar')
      puts "hyperlinking to #{url}"
      $stdout.flush
      @client = XMLRPC::Client.new2(url)
      @session = @client.proxy('session')
      @sid = @session.login_with_password(username, password)['Value']
    end

    def send(proxy, method, *args)
      p = ""
      if args.empty?
        return eval("@#{proxy.to_s}.#{method}(@sid)")
      else
        args.each do |a|
          p += ",'#{a}'"
        end
        return eval("@#{proxy.to_s}.#{method}(@sid #{p})")
      end
    end
  end

  class XObject

    def initialize(link, ref, proxy)
      @ref = ref
      @link = link
      @proxy = proxy
    end

    def ref_call(method)
      @proxy.send(method, @link.sid, @ref)['Value']
    end
    
  end

  class Host < XObject

    def initialize(link, ref, proxy)
      super(link, ref, proxy)
    end

    def uuid
      ref_call :get_uuid
    end

    def name_label
      ref_call :get_name_label
    end

    def resident_vms
      vms = []
      ref_call(:get_resident_VMs).each do |vm|
        vms << VM.new(@link, vm, @link.client.proxy('VM'))
      end
      vms
    end

    def metrics
      HostMetrics.new(@link, ref_call(:get_metrics), @link.client.proxy('host_metrics'))
    end

  end

  class HostMetrics < XObject
    def initialize(link, ref, proxy)
      super(link, ref, proxy)
    end

    def memory_total
      ref_call :get_memory_total
    end
    
    def memory_free
      ref_call :get_memory_free
    end
  end

  class VM < XObject
    def initialize(link, ref, proxy)
      super link, ref, proxy
    end

    def name_label
      ref_call :get_name_label
    end
  end 
end # module Pangea

