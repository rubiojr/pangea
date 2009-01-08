require 'xmlrpc/client'
require "#{File.join(File.dirname(__FILE__), 'memoizers/timed_memoizer.rb')}"
require "#{File.join(File.dirname(__FILE__), 'memoizers/simple_memoizer.rb')}"
require "#{File.join(File.dirname(__FILE__), 'memoizers/strategy.rb')}"
require "#{File.join(File.dirname(__FILE__), 'util/string.rb')}"

Module.send :include, Pangea::Memoizers.strategy

module Pangea

  VERSION = '0.0.20'

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

    #def send(proxy, method, *args)
    #  p = ""
    #  if args.empty?
    #    return eval("@#{proxy.to_s}.#{method}(@sid)")
    #  else
    #    args.each do |a|
    #      p += ",'#{a}'"
    #    end
    #    return eval("@#{proxy.to_s}.#{method}(@sid #{p})")
    #  end
    #end
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

    def uuid
      ref_call :get_uuid
    end
    
    memoize :uuid
  end

  class Host < XObject


    def initialize(link, ref, proxy)
      super(link, ref, proxy)
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

    #
    # There's no direct mapping to xen-api
    #
    def networks
      nets = [] 
      p = @link.client.proxy( 'network' )
      p.get_all(@link.sid)['Value'].each do |ref|
        nets << Network.new(@link, ref, p)
      end
      nets
    end

    def to_s
      "Label: #{label}\n" +
      "UUID: #{uuid}\n" +
      "Sched Policy: #{sched_policy}\n" +
      "Xen Version: #{software_version['Xen']}"
    end

    memoize :networks
    memoize :metrics
    memoize :sched_policy
    memoize :label
    memoize :resident_vms
    memoize :software_version
    memoize :cpus
  end

  class HostMetrics < XObject
    
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
    def utilisation
      ref_call :get_utilisation
    end

    memoize :model_name
    memoize :utilisation
    memoize :speed
    memoize :vendor
    memoize :number
  end


  class VM < XObject
    
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
    # xen-api: VM.get_guest_metrics
    #
    def guest_metrics
      VMGuestMetrics.new(@link, ref_call(:get_guest_metrics), @link.client.proxy('VM_guest_metrics'))
    end

    #
    # xen-api: VM.get_VIFs
    #
    def vifs
      list = []
      ref_call(:get_VIFs).each do |vif|
        list << VIF.new(@link, vif, @link.client.proxy('VIF'))
      end
      list
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
    def resident_on
      ref = ref_call(:get_resident_on)
      Host.new(@link, ref, @link.client.proxy('host'))
    end
    
    #
    # xen-api: VM.get_domid
    #
    def domid
      (ref = ref_call :get_domid).to_i
    end
    
    #
    # xen-api: VM.get_is_control_domain
    #
    def is_control_domain?
      ref_call :get_is_control_domain
    end
    
    #
    # xen-api: VM.get_auto_power_on
    #
    #def auto_power_on?
    #  puts ref_call :get_auto_power_on
    #end
    
    #
    # xen-api: VM.get_actions_after_shutdown
    #
    def actions_after_shutdown
      ref_call :get_actions_after_shutdown
    end
    
    #
    # xen-api: VM.get_pv_kernel
    #
    def pv_kernel
      ref_call :get_PV_kernel
    end
    
    #
    # xen-api: VM.get_actions_after_reboot
    #
    def actions_after_reboot
      ref_call :get_actions_after_reboot
    end
    
    #
    # xen-api: VM.get_actions_after_crash
    #
    def actions_after_crash
      ref_call :get_actions_after_crash
    end
    
    def to_s
      eol = "\n"
      "Label: #{label}" + eol +
      "UUID: #{uuid}" + eol +
      "Power State: #{power_state}" + eol +
      "Mem: #{Util::humanize_bytes(dyn_min_mem)}" + eol +
      "Max Mem: #{Util::humanize_bytes(max_mem)}" + eol
    end

    memoize :label
    memoize :metrics
    memoize :vifs
    memoize :actions_after_crash
    memoize :actions_after_reboot
    memoize :actions_after_shutdown
    memoize :domid
    memoize :resident_on
    memoize :power_state
    memoize :max_mem
    memoize :dyn_min_mem
    memoize :dyn_max_mem
  end 


  #
  # xen-api class: VM_guest_metrics
  #
  class VMGuestMetrics < XObject
  end

  #
  # xen-api class: VM_metrics
  #
  class VMMetrics < XObject
    
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
  
  class VIF < XObject
    
    #
    # xen-api: VIF.get_device
    #
    def device
      ref_call :get_device
    end
    
    #
    # xen-api: VIF.get_MAC
    #
    def mac
      ref_call :get_MAC
    end
    
    #
    # xen-api: VIF.get_metrics
    #
    def metrics
      VIFMetrics.new(@link, ref_call(:get_metrics), @link.client.proxy('VIF_metrics'))
    end

    #
    # xen-api: VIF.get_vm
    #
    def vm
      VM.new(@link, ref_call(:get_VM), @link.client.proxy('VM'))
    end

    #
    # xen-api: VIF.get_network
    # FIXME
    #
    #def network
    #  Network.new(@link, ref_call(:get_network), @link.client.proxy('network'))
    #end
    
    memoize :vm
    memoize :metrics
    memoize :mac
    memoize :device
  end

  class VIFMetrics < XObject

    def io_read_kbs
      ref_call :get_io_read_kbs
    end

    def io_write_kbs
      ref_call :get_io_write_kbs
    end
    memoize :io_read_kbs
    memoize :io_write_kbs
  end

  class Network < XObject
    def label
      ref_call :get_name_label
    end

    #
    # xen-api: network.get_default_gateway
    #
    # returns a string or nil if the gateway is not
    # defined.
    #
    def default_gateway
      gw = ref_call :get_default_gateway
      return nil if gw.strip.chomp.empty?
      gw
    end
    
    #
    # xen-api: network.get_default_netmask
    #
    # returns a string or nil if the netmask is not
    # defined.
    #
    def default_netmask
      nm = ref_call :get_default_netmask
      return nil if nm.strip.chomp.empty?
      gw
    end

    #
    # xen-api: network.get_VIFs
    #
    def vifs
      l = []
      ref_call(:get_VIFs).each do |ref|
        l << VIF.new(@link, ref, @link.client.proxy('VIF'))
      end
      l
    end

  end

end # module Pangea

