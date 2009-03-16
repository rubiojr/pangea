require 'test/unit'
require 'lib/pangea'
require 'test/config.rb'

class TestCluster < Test::Unit::TestCase

  def setup
    @hc = Pangea::Cluster.new(
      { 'test-hv1' => {
          'url' => TEST_HV
        }
      }
    )
  end

  def test_index
    l1 = @hc.nodes[0].label
    assert(@hc[l1] == @hc.nodes[0])
    assert(@hc[l1].label.is_a? String)

  end

  def test_nodes
    assert(@hc.nodes.size == 1)
    assert_nothing_raised do
      assert(@hc.nodes[0].label.is_a? String)
    end
  end

end
