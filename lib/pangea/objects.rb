module Pangea

  #
  # Link is the connection to the hypervisor
  # 
  # Every Link is associated to one host
  #
  class Link #:nodoc:

    attr_reader :client, :sid, :url, :connected

    def initialize(url, username='foo', password='bar')
      @xmlrpc_url = url
      @username = username
      @password = password
    end

    def connect
      #puts "hyperlinking to #{@xmlrpc_url}"
      $stdout.flush
      begin
        @client = XMLRPC::Client.new2(@xmlrpc_url)
        @session = @client.proxy('session')
        @sid = @session.login_with_password(@username, @password)['Value']
        @connected = true
      rescue Exception => e
        raise LinkConnectError.new("Error connecting to the hypervisor #{@xmlrpc_url} (#{e.message})")
      end
    end

  end

  #
  # Base class for every Xen Object
  #
  # Do not use this class.
  #
  # There's no direct mapping to xen-api AFAIK
  #
  class XObject #:nodoc:

    def initialize(link, ref)
      @ref = ref
      @link = link
      @proxy_name = nil
      @proxy = nil
    end

    def ref_call(method)
      if @proxy.nil?
        # first ref_call, init proxy
        @proxy = @link.client.proxy(@proxy_name)
      end
      begin
        return @proxy.send(method, @link.sid, @ref)['Value']
      rescue Exception => e
          raise ProxyCallError.new("Error sending request to proxy #{@proxy_name}. Link might be dead (#{e.message})")
      end
    end

    #
    # This is standard in every Xen Object
    #
    # Returns the unique identifier
    # 
    def uuid
      ref_call :get_uuid
    end
    
  end

  #
  # A Physical Host
  # 
  # xen-api: Class host
  #
  # <tt>
  # require 'pangea'
  #
  # host = Host.connect(\'http://xen.example.net', 'username', 'password')
  # </tt>
  #
  class Host < XObject
    
    def initialize(link, ref) #:nodoc:
      super(link, ref)
      @proxy_name = 'host'
    end
    
    #
    # Returns the label of the Host (hostname)
    #
    def label
      ref_call :get_name_label
    end

    #
    # Get the list of resident virtual machines controlled
    # by the hypervisor.
    #
    # Returns an Array of Pangea::VM objects 
    #
    # xen-api: host.get_resident_VMs
    #
    def resident_vms
      vms = []
      ref_call(:get_resident_VMs).each do |vm|
        vms << VM.new(@link, vm)
      end
      vms
    end

    # 
    # Get the list of resident virtual machines controlled
    # by the hypervisor.
    #
    # Returns an Array of Pangea::HostCpu objects 
    #
    # xen-api: host.get_host_cpus
    #
    def cpus
      list = []
      ref_call(:get_host_CPUs).each do |hcpu|
        list << HostCpu.new(@link, hcpu)
      end
      list
    end
    
    #
    # List some properties from the hypervisor:
    #
    # machine: Host Architecture
    # Xen:     Xen Version
    # system:  Host OS (i.e. Linux)
    # release: Xen Kernel Version
    # host:    hostname
    #
    # Returns a Hash
    #
    # xen-api: host.get_software_version
    #
    def software_version
      ref_call :get_software_version
    end
    
    #
    # Get the Xen scheduling policy
    #
    # Returns a string
    #
    # xen-api: host.get_sched_policy
    #
    def sched_policy
      ref_call :get_sched_policy
    end

    #
    # Get the Pangea::HostMetrics object for this host
    #
    # xen-api: host.get_metrics
    #
    def metrics
      HostMetrics.new(@link, ref_call(:get_metrics))
    end

    #
    # Returns the list of networks available in this host
    #
    # If you are using a bridged network configuration
    # ('network-script network-bridge' in xend-config.sxp), it will 
    # return an Array of Pangea::Network objects available in the host,
    # one for each bridge available.
    # 
    # There's no direct mapping to xen-api AFAIK
    #
    def networks
      nets = [] 
      p = @link.client.proxy( 'network' )
      p.get_all(@link.sid)['Value'].each do |ref|
        nets << Network.new(@link, ref)
      end
      nets
    end

    def to_s
      "Label: #{label}\n" +
      "UUID: #{uuid}\n" +
      "Sched Policy: #{sched_policy}\n" +
      "Xen Version: #{software_version['Xen']}"
    end

    #
    # Connect to the Host xml-rpc server
    #
    # Returns a Pangea::Host object
    #
    # There's no direct mapping to xen-api
    #
    def self.connect(url, username, password)
      @link = Link.new(url, username, password)
      @link.connect
      @ref = @link.client.call('host.get_all', @link.sid)['Value'][0]
      Host.new(@link, @ref)
    end

    #
    # Reconnect to the Host
    #
    # There's no direct mapping to xen-api
    #
    def reconnect
      raise LinkConnectError.new("You need to connect at least once before reconnecting") if @link.nil?
      @link.connect
      @ref = @link.client.call('host.get_all', @link.sid)['Value'][0]
    end

    #
    # Checks if the connection to the host xml-rpc server is alive
    #
    # There's no direct mapping to xen-api
    #
    def alive?
      begin
        ref_call :get_uuid
      rescue Exception => e
        #puts e.message
        return false
      end
      true
    end
    
  end

  #
  # The metrics associated with a host
  #
  # xen-api: Class host_metrics
  # 
  class HostMetrics < XObject

    def initialize(link, ref) #:nodoc:
      super(link, ref)
      @proxy_name = 'host_metrics'
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
    
  end
  
  #
  # A Physical CPU
  #
  # xen-api: Class host_cpu
  #
  class HostCpu < XObject

    def initialize(link, ref) #:nodoc:
      super(link, ref)
      @proxy_name = 'host_cpu'
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
    def utilisation
      ref_call :get_utilisation
    end

  end


  #
  # A Virtual Machine or Guest (DomU)
  #
  # xen-api: VM
  # 
  class VM < XObject
    
    def initialize(link, ref) #:nodoc:
      super(link, ref)
      @proxy_name = 'VM'
    end

    #
    # VM Label (same one you see when you run 'xm list')
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
      VMMetrics.new(@link, ref_call(:get_metrics))
    end
    
    #
    # xen-api: VM.get_guest_metrics
    #
    def guest_metrics
      VMGuestMetrics.new(@link, ref_call(:get_guest_metrics))
    end

    #
    # xen-api: VM.get_VIFs
    #
    def vifs
      list = []
      ref_call(:get_VIFs).each do |vif|
        list << VIF.new(@link, vif)
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
      Host.new(@link, ref)
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

  end 


  #
  # Metrics reported by the guest (from 'inside' the guest)
  #
  # xen-api: Class VM_guest_metrics
  #
  class VMGuestMetrics < XObject
    def initialize(link, ref) #:nodoc:
      super(link, ref)
      @proxy_name = 'VM_guest_metrics'
    end
  end

  #
  # Metrics associated with a VM
  #
  # xen-api class: VM_metrics
  #
  class VMMetrics < XObject
    
    def initialize(link, ref) #:nodoc:
      super(link, ref)
      @proxy_name = 'VM_metrics'
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
  
  class VIF < XObject
    
    def initialize(link, ref) #:nodoc:
      super(link, ref)
      @proxy_name = 'VIF'
    end
    
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
      VIFMetrics.new(@link, ref_call(:get_metrics))
    end

    #
    # xen-api: VIF.get_vm
    #
    def vm
      VM.new(@link, ref_call(:get_VM))
    end

    #
    # xen-api: VIF.get_network
    # FIXME
    #
    #def network
    #  Network.new(@link, ref_call(:get_network), @link.client.proxy('network'))
    #end
    
  end

  #
  # Metrics associated with a virtual network device
  #
  # xen-api: Class VIF_metrics
  #
  class VIFMetrics < XObject

    def initialize(link, ref) #:nodoc:
      super(link, ref)
      @proxy_name = 'VIF_metrics'
    end

    #
    # VIF input Kbits/s
    #
    # xen-api: VIF_metrics.get_io_read_kbs
    #
    def io_read_kbs
      ref_call :get_io_read_kbs
    end

    #
    # VIF output Kbits/s
    #
    # xen-api: VIF_metrics.get_io_read_kbs
    #
    def io_write_kbs
      ref_call :get_io_write_kbs
    end
  end

  class Network < XObject
    def initialize(link, ref) #:nodoc:
      super(link, ref)
      @proxy_name = 'network'
    end

    def label
      ref_call :get_name_label
    end

    #
    # Returns a string or nil if the gateway is not
    # defined.
    #
    # xen-api: network.get_default_gateway
    #
    def default_gateway
      gw = ref_call :get_default_gateway
      return nil if gw.strip.chomp.empty?
      gw
    end
    
    #
    # Returns a string or nil if the netmask is not
    # defined.
    #
    # xen-api: network.get_default_netmask
    #
    def default_netmask
      nm = ref_call :get_default_netmask
      return nil if nm.strip.chomp.empty?
      gw
    end

    #
    # Virtual Interfaces bridged to the network bridge
    #
    # xen-api: network.get_VIFs
    #
    def vifs
      l = []
      ref_call(:get_VIFs).each do |ref|
        l << VIF.new(@link, ref)
      end
      l
    end

  end

end # module Pangea

