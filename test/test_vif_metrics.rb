require 'test/unit'
require 'lib/pangea'
require 'test/config.rb'

class TestVIFMetrics < Test::Unit::TestCase

  def setup
    @hc = Pangea::Cluster.new(
      { 'xen7' => {
          'url' => TEST_HV
        }
      }
    )
  end

  def test_uuid
    @hc.hosts[0].resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.metrics.uuid.is_a? String )
      end
    end
  end

  def test_io_read_kbs
    @hc.hosts[0].resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.metrics.io_read_kbs.is_a? Float )
      end
    end
  end

  def test_io_write_kbs
    @hc.hosts[0].resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.metrics.io_write_kbs.is_a? Float )
      end
    end
  end

end
