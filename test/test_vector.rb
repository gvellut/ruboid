$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ruboid'
require 'test/unit'

include Ruboid

class TestVector < Test::Unit::TestCase
  
  def test_add
    a = Vector.new([1,2])
    b = Vector.new([3,4])
    assert_equal([4,6],a.add(b).coords)
  end

  def test_sub
    a = Vector.new([1.5,2.6])
    b = Vector.new([3.1,4.7])
    assert_equal([-1.6,-2.1],a.sub(b).coords)
  end

  def test_mul
    a = Vector.new([1.5,2.6])
    assert_equal([3.0,5.2],a.mul(2).coords)
  end

  def test_div
    a = Vector.new([1.5,2.6])
    assert_equal([0.75,1.3],a.div(2).coords)
  end

  def test_equal
    a = Vector.new([1.5,2.6])
    b = Vector.new([3.1,4.7])
    assert(a != b)
    
    c = Vector.new([1.5,2.6])
    assert(a == c)
  end

  def test_dimension
    assert_equal(2,Vector.new([1.5,2.6]).dimension)
  end

  def test_modification
    a = Vector.new([1.5,2.6])
    a[0] = 2

    assert_equal([2,2.6],a.coords)
    assert_equal(2,a[0])
  end

  def test_zero
    a = Vector.zero(2)
    assert_equal(2,a.dimension)
    assert_equal([0,0],a.coords)
  end

  def test_norm
    a = Vector.new([3,4])
    assert_equal(5,a.norm)
  end

  def test_distance_to
    a = Vector.new([2,3])
    b = Vector.new([2,9])

    assert_equal(6,a.distance_to(b))
  end

end
