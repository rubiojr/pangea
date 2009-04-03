require 'test/unit'
require 'lib/pangea'
require 'test/config.rb'

class TestNetwork< Test::Unit::TestCase

  def setup
    @host = Pangea::Host.connect(TEST_HV, 'foo', 'bar')
  end

  def test_uuid
    @host.networks.each do |net|
      assert( net.uuid.is_a? String )
    end
  end

  def test_label
    @host.networks.each do |net|
      assert( net.label.is_a? String )
    end
  end

  def test_default_gateway
    @host.networks.each do |net|
      assert( net.default_gateway.is_a?(String) || net.default_gateway.nil? )
    end
  end
  
  def test_default_netmask
    @host.networks.each do |net|
      assert( net.default_netmask.is_a?(String) || net.default_netmask.nil? )
    end
  end

  def test_vifs
    @host.networks.each do |net|
      net.vifs.each do |vif|
        assert( vif.is_a? Pangea::VIF )
      end
    end
  end

end
