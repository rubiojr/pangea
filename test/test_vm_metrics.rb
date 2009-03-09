require 'test/unit'
require 'lib/pangea'
require 'test/config.rb'

class TestVMMetrics < Test::Unit::TestCase

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
      assert( vm.metrics.uuid.is_a? String )
    end
  end

end
