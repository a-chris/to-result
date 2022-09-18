require 'minitest/autorun'
require 'byebug'

require './lib/to_result'

class ToResultTest < Minitest::Test
  include ToResultMixin

  def setup
    @value = 'hello world!'
  end

  def test_string
    assert ToResult { @value } == Success(@value)
  end

  def test_success
    expected = Success(@value)
    assert ToResult { expected } == Success(expected)
  end

  def test_exception
    expected = StandardError.new(@value)
    assert ToResult { raise expected } == Failure(expected)
  end

  def test_exception_included_in_exceptions_list
    expected = ArgumentError.new(@value)
    assert ToResult([ArgumentError]) { raise expected } == Failure(expected)
  end

  def test_exception_not_included_in_exceptions_list
    expected = NameError.new(@value)
    assert_raises(NameError) { ToResult([ArgumentError]) { raise expected } }
  end

  def test_yield_failure
    expected = Failure(@value)
    # this will raise a Dry::Monads::Do::Halt exception
    assert ToResult { yield expected } == expected
  end

  def test_yield_failure_exception
    expected = Failure(StandardError.new(@value))
    # this will raise a Dry::Monads::Do::Halt exception
    assert ToResult { yield expected } == expected
  end
end
