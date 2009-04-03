require 'test/unit'
require 'lib/pangea'
require 'test/config.rb'

class TestVIFMetrics < Test::Unit::TestCase

  def setup
    @host = Pangea::Host.connect(TEST_HV, 'foo', 'bar')
  end

  def test_uuid
    @host.resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.metrics.uuid.is_a? String )
      end
    end
  end

  def test_io_read_kbs
    @host.resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.metrics.io_read_kbs.is_a? Float )
      end
    end
  end

  def test_io_write_kbs
    @host.resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.metrics.io_write_kbs.is_a? Float )
      end
    end
  end

end
