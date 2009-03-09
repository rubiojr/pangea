require 'test/unit'
require 'lib/pangea'
require 'test/config.rb'

class TestNetwork< Test::Unit::TestCase

  def setup
    @hc = Pangea::Cluster.new(
      { 'xen7' => {
          'url' => TEST_HV
        }
      }
    )
  end

  def test_uuid
    @hc.hosts[0].networks.each do |net|
      assert( net.uuid.is_a? String )
    end
  end

  def test_label
    @hc.hosts[0].networks.each do |net|
      assert( net.label.is_a? String )
    end
  end

  def test_default_gateway
    @hc.hosts[0].networks.each do |net|
      assert( net.default_gateway.is_a?(String) || net.default_gateway.nil? )
    end
  end
  
  def test_default_netmask
    @hc.hosts[0].networks.each do |net|
      assert( net.default_netmask.is_a?(String) || net.default_netmask.nil? )
    end
  end

  def test_vifs
    @hc.hosts[0].networks.each do |net|
      net.vifs.each do |vif|
        assert( vif.is_a? Pangea::VIF )
      end
    end
  end

end
