require 'abnf'
require 'test/unit'

require 'pp'

class TestABNF < Test::Unit::TestCase
  def test_non_recursion_1
    assert_equal('[Aa]', ABNF.ruby_regexp(<<-'End').to_s)
      n = "a"
    End
  end

  def test_left_recursion_1
    assert_equal('[Aa][Bb]*', ABNF.ruby_regexp(<<-'End').to_s)
      n = "a" | n "b"
    End
  end

  def test_left_recursion_2
    assert_equal('[Aa][Bb]*', ABNF.ruby_regexp(<<-'End').to_s)
      n = "a" | n2 "b"
      n2 = n
    End
  end

  def test_right_recursion_1
    assert_equal('[Bb]*[Aa]', ABNF.ruby_regexp(<<-'End').to_s)
      n = "a" | "b" n
    End
  end

  def test_both_recursion_1
    assert_equal('[Aa]*[Bb][Cc]*', ABNF.ruby_regexp(<<-'End').to_s)
      n = "a" n | "b" | n "c"
    End
  end

  def test_both_recursion_2
    assert_equal('[Aa]*[Bb][Cc]*', ABNF.ruby_regexp(<<-'End').to_s)
      n = "a" n | "b" | n "c" | n
    End
  end

  def test_unreachable_1
    assert_equal([:s, :n], ABNF.parse(<<-'End').delete_unreachable([:s]).names)
      s = "a" | n
      n = "b"
      m = "c"
    End
  end

  def test_useless_1
    assert_equal([:s, :n], ABNF.parse(<<-'End').delete_useless(:s).names)
      s = "a" | n
      n = "b"
      m = "c"
    End
  end

  def test_useless_2
    assert_equal([:s, :n], ABNF.parse(<<-'End').delete_useless(:s).names)
      s = "a" | n | x
      n = "b"
      x = y
      y = x
      m = "c"
    End
  end

end
