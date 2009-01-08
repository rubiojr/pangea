require 'test/unit'
require 'lib/pangea'

class TestVIFMetrics < Test::Unit::TestCase

  def setup
    @hc = Pangea::Cluster.new(
      { 'xen7' => {
          'url' => 'http://xen7.gestion.privada.csic.es:9363'
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
