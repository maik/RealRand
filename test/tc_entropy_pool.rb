#!/usr/bin/env ruby

require 'test/unit'
require '../lib/random/online'

class TC_EntropyPool < Test::Unit::TestCase # :nodoc:
  def setup
    @generator = Random::EntropyPool.new
  end

  def test_illegal_amount
    [257, -1].each { |x| 
      assert_raises(RangeError) { @generator.randbyte(x) }
    }
  end
  
  def test_zero_amount
    assert_equal([], @generator.randbyte(0))
  end
  
  def test_randbyte
    [1, 2, 10, 256].each { |x|
      numbers = @generator.randbyte(x, false)
      assert(x > 0 && x >= numbers.length)
    }
  end
end

# vim:sw=2

