require 'xmlrpc/client'

module Pangea

  VERSION = '0.0.1'

  module Util

    def self.humanize_bytes(bytes)
      m = bytes.to_i
      units = %w[Bits Bytes MB GB]
      while (m/1024.0) >= 1 
        m = m/1024.0
        units.shift
      end
      return m.round.to_s + " #{units[0]}"
    end

  end

  class Cluster
    def initialize(hosts={})
      @index = {}
      @links = []
      hosts.each_key do |n|
        @links << Link.new(hosts[n]['url'], 
                                  hosts[n]['username'] || '', 
                                  hosts[n]['passwor'] || ''
                                  ) 
      end
    end

    def [](name)
      hosts if @index.empty?
      @index[name]
    end

    def hosts
      list = []
      @links.each do |hl|
        ref = hl.client.call('host.get_all', hl.sid)['Value'][0]
        h = Host.new(hl, ref, hl.client.proxy('host'))
        @index[h.name_label] = h
        list << h
      end
      list
    end
  end

  class Link

    attr_reader :client, :session, :sid, :url, :password, :username

    def initialize(url, username='foo', password='bar')
      @xmlrpc_url = url
      @username = username
      @password = password
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

