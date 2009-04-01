module Pangea
  #
  # A Xen Cluster is a group of Hosts
  #
  class Cluster

    def initialize(config={})
      @index = {}
      @config = config 
      @nodes = []
    end

    def [](name)
      # initialize the node list
      nodes if @index.empty?
      @index[name]
    end

    # Deprecated, use Cluster.nodes
    def hosts
      puts "WARNING: Cluster.hosts is deprecated. Use Cluster.nodes instead"
      nodes
    end

    #
    # Returns the list of nodes in the Cluster
    #
    def nodes
      return @nodes if (not @nodes.nil? and @nodes.size > 0)
      init_nodes
      @nodes
    end

    private
    def init_nodes
      @config.each_key do |n|
        h = Host.connect(@config[n]['url'], 
                           @config[n]['username'] || '', 
                           @config[n]['password'] || ''
                          ) 
        @index[h.label] = h
        @nodes << h
      end
    end
  end
end
