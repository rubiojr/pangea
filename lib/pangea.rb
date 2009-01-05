require 'xmlrpc/client'
require "#{File.join(File.dirname(__FILE__), 'memoizers/timed_memoizer.rb')}"
require "#{File.join(File.dirname(__FILE__), 'memoizers/simple_memoizer.rb')}"
require "#{File.join(File.dirname(__FILE__), 'memoizers/strategy.rb')}"
require "#{File.join(File.dirname(__FILE__), 'util/string.rb')}"

Module.send :include, Pangea::Memoizers.strategy

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
        @index[h.label] = h
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

    def label
      ref_call :get_name_label
    end

    def resident_vms
      vms = []
      ref_call(:get_resident_VMs).each do |vm|
        vms << VM.new(@link, vm, @link.client.proxy('VM'))
      end
      vms
    end

    # 
    # xen-api: Host.get_host_cpus
    #
    def cpus
      list = []
      ref_call(:get_host_CPUs).each do |hcpu|
        list << HostCpu.new(@link, hcpu, @link.client.proxy('host_cpu'))
      end
      list
    end
    
    #
    # xen-api: Host.get_software_version
    #
    # Returns a Hash
    #
    def software_version
      ref_call :get_software_version
    end
    
    #
    # xen-api: Host.get_sched_policy
    #
    def sched_policy
      ref_call :get_sched_policy
    end

    def metrics
      HostMetrics.new(@link, ref_call(:get_metrics), @link.client.proxy('host_metrics'))
    end

    def to_s
      "Label: #{label}\n" +
      "UUID: #{uuid}\n" +
      "Sched Policy: #{sched_policy}\n" +
      "Xen Version: #{software_version['Xen']}"
    end
    
    memoize :metrics
    memoize :sched_policy
    memoize :label
    memoize :resident_vms
    memoize :software_version
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

    def to_s
      "Total Memory: #{Pangea::Util.humanize_bytes(memory_total)}\n" +
      "Free Memory: #{Pangea::Util.humanize_bytes(memory_free)}"
    end
    
    memoize :memory_free
    memoize :memory_total
  end
  
  class HostCpu < XObject
    def initialize(link, ref, proxy)
      super(link, ref, proxy)
    end

    #
    # xen-api: host_cpu.get_number
    #
    def number
      ref_call :get_number
    end
    
    #
    # xen-api: host_cpu.get_vendor
    #
    def vendor
      ref_call :get_vendor
    end
    
    #
    # xen-api: host_cpu.get_speed
    #
    # CPU Speed in MHz
    #
    def speed
      ref_call :get_speed
    end
    
    #
    # xen-api: host_cpu.get_modelname
    #
    # CPU Model
    #
    def model_name
      ref_call :get_modelname
    end
    
    #
    # xen-api: host_cpu.get_utilisation
    #
    # CPU Utilisation
    #
    def model_name
      ref_call :get_utilisation
    end

    memoize :model_name
    memoize :speed
    memoize :vendor
    memoize :number
  end


  class VM < XObject
    def initialize(link, ref, proxy)
      super link, ref, proxy
    end
    
    #
    # xen-api: VM.get_uuid
    #
    def uuid
      ref_call :get_uuid
    end

    #
    # xen-api: VM.get_name_label
    #
    def label
      ref_call :get_name_label
    end
    
    #
    # xen-api: VM.get_metrics
    #
    def metrics
      VMMetrics.new(@link, ref_call(:get_metrics), @link.client.proxy('VM_metrics'))
    end

    #
    # xen-api: VM.get_power_state
    # 
    def power_state
      ref_call :get_power_state
    end

    #
    # xen-api: VM.get_memory_static_max
    #
    def max_mem
      ref_call :get_memory_static_max
    end
    
    def dyn_max_mem
      ref_call :get_memory_dynamic_max
    end

    def dyn_min_mem
      ref_call :get_memory_dynamic_min
    end

    #
    # xen-api: VM.get_memory_static_min
    #
    def min_mem
      ref_call :get_memory_static_min
    end

    #
    # xen-api: VM.get_resident_on
    #
    #def resident_on
    #  ref = ref_cal :get_power_state
    #  Host.new(hl, ref, hl.client.proxy('host'))
    #end
    
    def to_s
      eol = "\n"
      "Label: #{label}" + eol +
      "Power State: #{power_state}" + eol +
      "Mem: #{Util::humanize_bytes(dyn_min_mem)}" + eol +
      "Max Mem: #{Util::humanize_bytes(max_mem)}" + eol
    end

    memoize :label
    memoize :metrics
  end 

  #
  # xen-api class: VM_metrics
  #
  class VMMetrics < XObject
    
    def initialize(link, ref, proxy)
      super(link, ref, proxy)
    end

    #
    # xen-api: VM_metrics.get_memory_actual
    #
    def memory_actual
      ref_call :get_memory_actual
    end

    #
    # xen-api: VM_metrics.get_VCPUs_number
    # Number of cpus assigned to the domU
    #
    def vcpus_number
      ref_call :get_VCPUs_number
    end
    
    #
    # xen-api: VM_metrics.get_VCPUs_utilisation
    #
    # returns a hash
    # {
    #   cpu0 => utilisation,
    #   cpu1 => utilization,
    #   ...
    # }
    #  
    def vcpus_utilisation
      ref_call :get_VCPUs_utilisation
    end

    #
    # xen-api: VM_metrics.get_state
    # 
    def state
      ref_call :get_state
    end

    #
    # xen-api: VM_metrics.get_start_time
    #
    def start_time
      (ref_call :get_start_time).to_time
    end

    #
    # xen-api: VM_metrics.get_last_updated
    #
    def last_updated
      (ref_call :get_last_updated).to_time
    end

    def to_s
      vcpu_u = ""
      vcpus_utilisation.each do |k, v|
        vcpu_u += "#{k}: %0.2f\n" % (v * 100)
      end
      eol = "\n"
      "[VM Metrics]" + eol +
      "State: #{state}" + eol +
      "Start Time: #{start_time}" + eol +
      "Last Updated: #{last_updated}" + eol +
      "VCPUs Utilisation:" + eol +
      vcpu_u
    end
  end
end # module Pangea

