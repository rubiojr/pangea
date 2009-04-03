require 'test/unit'
require 'lib/pangea'
require 'test/config.rb'

class TestVIF < Test::Unit::TestCase

  def setup
    @host = Pangea::Host.connect(TEST_HV, 'foo', 'bar')
  end

  def test_mac
    @host.resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.mac.is_a? String )
      end
    end
  end
  
  def test_uuid
    @host.resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.uuid.is_a? String )
      end
    end
  end

  def test_device
    @host.resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.device.is_a? String )
      end
    end
  end

  def test_metrics
    @host.resident_vms.each do |vm|
      vm.vifs.each do |vif|
        vif.metrics.is_a? Pangea::VIFMetrics
      end
    end
  end
  
  #def test_network
  #  @host.resident_vms.each do |vm|
  #    vm.vifs.each do |vif|
  #      assert( vif.network.is_a? Pangea::Network )
  #    end
  #  end
  #end

  def test_vm
    @host.resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.vm.is_a? Pangea::VM )
      end
    end
  end

end
