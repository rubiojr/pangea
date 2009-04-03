require 'test/unit'
require 'lib/pangea'
require 'test/config.rb'

class TestVMMetrics < Test::Unit::TestCase

  def setup
    @host = Pangea::Host.connect(TEST_HV, 'foo', 'bar')
  end

  def test_uuid
    @host.resident_vms.each do |vm|
      assert( vm.metrics.uuid.is_a? String )
    end
  end

end
