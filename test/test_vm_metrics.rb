require 'test/unit'
require 'lib/pangea'

class TestVMMetrics < Test::Unit::TestCase

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
      assert( vm.metrics.uuid.is_a? String )
    end
  end

end
