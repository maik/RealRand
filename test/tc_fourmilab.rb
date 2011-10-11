#!/usr/bin/env ruby

require 'test/unit'
require '../lib/random/online'

class TC_FourmiLab < Test::Unit::TestCase # :nodoc:
  def setup
    @generator = RealRand::FourmiLab.new
  end

  def test_illegal_amount
    [2049, -1].each { |x| 
      assert_raises(RangeError) { @generator.randbyte(x) }
    }
  end
  
  def test_zero_amount
    assert_equal([], @generator.randbyte(0))
  end
  
  def test_randbyte
    [1, 2, 10, 2048].each do |x|
      numbers = @generator.randbyte(x)
      assert_equal(x, numbers.length)
    end
  end
end

# vim:sw=2

