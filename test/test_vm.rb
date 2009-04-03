require 'test/unit'
require 'lib/pangea'
require 'test/config.rb'

class TestVM < Test::Unit::TestCase

  def setup
    @host = Pangea::Host.connect(TEST_HV, 'foo', 'bar')
  end

  def test_domid
    @host.resident_vms.each do |vm|
      assert( vm.domid.is_a?(Fixnum) )
    end
  end

  def test_is_control_domain?
    @host.resident_vms.each do |vm|
      assert( 
             vm.is_control_domain?.is_a?(TrueClass) || \
             vm.is_control_domain?.is_a?(FalseClass) 
            )
    end
  end

  def test_actions_after_shutdown
    @host.resident_vms.each do |vm|
      assert( ['restart', 'destroy' ].include? vm.actions_after_shutdown )
    end
  end
  
  def test_actions_after_reboot
    @host.resident_vms.each do |vm|
      assert( ['restart', 'destroy' ].include? vm.actions_after_reboot )
    end
  end
  
  def test_pv_kernel
    @host.resident_vms.each do |vm|
      assert( vm.pv_kernel.is_a?(String) )
    end
  end

  def test_vifs
    @host.resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.is_a? Pangea::VIF )
      end
    end
  end
  
  def test_metrics
    @host.resident_vms.each do |vm|
      assert( vm.metrics.is_a? Pangea::VMMetrics )
    end
  end
  
  def test_guest_metrics
    @host.resident_vms.each do |vm|
      assert( vm.guest_metrics.is_a? Pangea::VMGuestMetrics )
    end
  end

  def test_resident_on
    @host.resident_vms.each do |vm|
      assert( vm.resident_on.is_a?(Pangea::Host) )
      assert( vm.resident_on.uuid.is_a?(String) )
    end
  end

end
