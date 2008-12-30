require 'xmlrpc/client'
require "#{File.join(File.dirname(__FILE__), 'memoizers/timed_memoizer.rb')}"
require "#{File.join(File.dirname(__FILE__), 'memoizers/simple_memoizer.rb')}"
require "#{File.join(File.dirname(__FILE__), 'memoizers/strategy.rb')}"
require "#{File.join(File.dirname(__FILE__), 'util/string.rb')}"

Module.send :include, Pangea::Memoizers::Strategy

module Pangea

  VERSION = '0.0.10'

  class Cluster

    def initialize(nodes={})
      @index = {}
      @links = []
      @nodes = nodes
    end

    def [](name)
      hosts if @index.empty?
      @index[name]
    end

    def hosts
      init_links
      list = []
      @links.each do |hl|
        ref = hl.client.call('host.get_all', hl.sid)['Value'][0]
        h = Host.new(hl, ref, hl.client.proxy('host'))
        @index[h.name_label] = h
        list << h
      end
      list
    end

    private
    def init_links
      return if not @links.empty?
      @nodes.each_key do |n|
        @links << Link.new(@nodes[n]['url'], 
                           @nodes[n]['username'] || '', 
                           @nodes[n]['password'] || ''
                          ) 
      end
    end
    
    memoize :hosts
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
    
    memoize :metrics
    memoize :name_label
    memoize :resident_vms
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
    
    memoize :memory_free
    memoize :memory_total
  end

  class VM < XObject
    def initialize(link, ref, proxy)
      super link, ref, proxy
    end

    def name_label
      ref_call :get_name_label
    end

    memoize :name_label
  end 
end # module Pangea

