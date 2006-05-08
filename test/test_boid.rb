$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ruboid'
require 'test/unit'

include Ruboid

class TestRuboid < Test::Unit::TestCase

  def test_ruboid
    assert(true)
  end

end
