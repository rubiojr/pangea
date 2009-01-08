require 'test/unit'
require 'lib/pangea'

class TestVM < Test::Unit::TestCase

  def setup
    @hc = Pangea::Cluster.new(
      { 'xen7' => {
          'url' => 'http://xen7.gestion.privada.csic.es:9363'
        }
      }
    )
  end

  def test_domid
    @hc.hosts[0].resident_vms.each do |vm|
      assert( vm.domid.is_a?(Fixnum) )
    end
  end

  def test_is_control_domain?
    @hc.hosts[0].resident_vms.each do |vm|
      assert( 
             vm.is_control_domain?.is_a? (TrueClass) || \
             vm.is_control_domain?.is_a?(FalseClass) 
            )
    end
  end

  def test_actions_after_shutdown
    @hc.hosts[0].resident_vms.each do |vm|
      assert( ['restart', 'destroy' ].include? vm.actions_after_shutdown )
    end
  end
  
  def test_actions_after_reboot
    @hc.hosts[0].resident_vms.each do |vm|
      assert( ['restart', 'destroy' ].include? vm.actions_after_reboot )
    end
  end
  
  def test_pv_kernel
    @hc.hosts[0].resident_vms.each do |vm|
      assert( vm.pv_kernel.is_a?(String) )
    end
  end

  def test_vifs
    @hc.hosts[0].resident_vms.each do |vm|
      vm.vifs.each do |vif|
        assert( vif.is_a? Pangea::VIF )
      end
    end
  end
  
  def test_metrics
    @hc.hosts[0].resident_vms.each do |vm|
      assert( vm.metrics.is_a? Pangea::VMMetrics )
    end
  end
  
  def test_guest_metrics
    @hc.hosts[0].resident_vms.each do |vm|
      assert( vm.guest_metrics.is_a? Pangea::VMGuestMetrics )
    end
  end

end
