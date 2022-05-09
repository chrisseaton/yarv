# frozen_string_literal: true

$:.unshift(File.expand_path("../lib", __dir__))
require "yarv"

require "stringio"
require "test/unit"

class YARVTest < Test::Unit::TestCase
  def test_opt_plus
    assert_insns([YARV::PutObject, YARV::PutObject, YARV::OptPlus, YARV::Leave], "2 + 3")
    assert_stdout("5\n", "p 2 + 3")
  end

  def test_opt_str_uminus
    assert_insns([YARV::OptStrUMinus, YARV::Leave], "-\"string\"")
    assert_stdout("\"string\"\n", "p -'string'")
  end

  def test_opt_minus
    assert_insns([YARV::PutObject, YARV::PutObject, YARV::OptMinus, YARV::Leave], "3 - 2")
    assert_stdout("1\n", "p 3 - 2")
  end

  private

  def assert_insns(expected, code)
    iseq = YARV.compile(code)
    assert_equal(expected, iseq.insns.map(&:class))
  end

  def assert_stdout(expected, code)
    original = $stdout
    $stdout = StringIO.new

    YARV.emulate(code)
    assert_equal(expected, $stdout.string)
  ensure
    $stdout = original
  end
end
