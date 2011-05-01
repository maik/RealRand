#!/usr/bin/env ruby

require 'test/unit'
require '../lib/random/online'

class TC_RandomOrg < Test::Unit::TestCase # :nodoc:
  def setup
    @generator = Random::RandomOrg.new
  end
  
  def test_illegal_amount
    [10_001, -1].each { |x| 
      assert_raises(RangeError) { @generator.randnum(x, 1, 100) }
    }

    [16_385, -1].each { |x| 
      assert_raises(RangeError) { @generator.randbyte(x) }
    }

    [
      [1, -1_000_000_001, 100],
      [1, 1, 1_000_000_001],
      [1, 1, 0],
      [1, 1, 1],
    ].each { |num, min, max|
      assert_raises(RangeError) { @generator.randnum(num, min, max) }
    }
  end
  
  def test_zero_amount
    assert_raises(RangeError) {
      @generator.randnum(0, 1, 100)
    }
    assert_raise(RangeError) {
      @generator.randbyte(0)
    }
  end
  
  def test_randnum
    [
      [1, -1_000_000_000, 1_000_000_000],
      [1, 1, 2],
      [5, 20, 100],
      [1000, 1, 6],
    ].each { |num, min, max|
      numbers = @generator.randnum(num, min, max)
      assert_equal(num, numbers.length)
      numbers.each { |x| assert(x >= min && x <= max) }
    }
  end

  def test_randbyte
    [1, 2, 10, 100].each { |x|
      numbers = @generator.randbyte(x)
      assert_equal(x, numbers.length)
    }
  end
end

# vim:sw=2

