require 'test/unit/ui/console/testrunner'
require 'test/unit/testsuite'
require 'test/test_vm'
require 'test/test_vif_metrics'
require 'test/test_network'
require 'test/test_vif'

class TS_Pangea
  def self.suite
    suite = Test::Unit::TestSuite.new
    suite << TestVM.suite
    suite << TestVIF.suite
    suite << TestNetwork.suite
    suite << TestVIFMetrics.suite
    return suite
  end
end
Test::Unit::UI::Console::TestRunner.run(TS_Pangea)

