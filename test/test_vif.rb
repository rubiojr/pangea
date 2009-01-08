require 'test/unit'
require 'lib/pangea'

class TestVIF < Test::Unit::TestCase

  def setup
    @hc = Pangea::Cluster.new(
      { 'xen7' => {
          'url' => 'http://xen7.gestion.privada.csic.es:9363'
        }
      }
    )
  end

  def test_mac
    @hc.hosts[0].resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.mac.is_a? String )
      end
    end
  end
  
  def test_uuid
    @hc.hosts[0].resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.uuid.is_a? String )
      end
    end
  end

  def test_device
    @hc.hosts[0].resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.device.is_a? String )
      end
    end
  end

  def test_metrics
    @hc.hosts[0].resident_vms.each do |vm|
      vm.vifs.each do |vif|
        vif.metrics.is_a? Pangea::VIFMetrics
      end
    end
  end
  
  #def test_network
  #  @hc.hosts[0].resident_vms.each do |vm|
  #    vm.vifs.each do |vif|
  #      assert( vif.network.is_a? Pangea::Network )
  #    end
  #  end
  #end

  def test_vm
    @hc.hosts[0].resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.vm.is_a? Pangea::VM )
      end
    end
  end

end
