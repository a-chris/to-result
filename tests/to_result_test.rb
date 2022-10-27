require 'minitest/autorun'
require 'mocha/minitest'
require 'byebug'

require './lib/to-result'
require './tests/support/fake_logger'

class ToResultTest < Minitest::Test
  include ToResultMixin

  def setup
    super
    @value = 'hello world!'
  end

  def teardown
    super

    # reset the configuration after each test
    ToResultMixin.configure { |c| c = {} }
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
    assert ToResult(only: [ArgumentError]) { raise expected } == Failure(expected)
  end

  def test_exception_not_included_in_exceptions_list
    expected = NameError.new(@value)
    assert_raises(NameError) { ToResult(only: [ArgumentError]) { raise expected } }
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

  def setup_global_on_error
    # creating a clean room just for testing purpose
    clean_room = Class.new(Object)
    clean_room.new.instance_eval do
      ToResultMixin.configure do |c|
        c.on_error = Proc.new { FakeLogger.log_error }
      end
    end
  end

  def test_global_on_error
    setup_global_on_error

    FakeLogger.expects(:log_error).once

    expected = StandardError.new(@value)
    assert ToResult { raise expected } == Failure(expected)
  end

  def test_local_on_error_overrides_global
    setup_global_on_error

    FakeLogger.expects(:log_error).once

    local_on_error = Proc.new { FakeLogger.log_error }

    expected = StandardError.new(@value)
    assert ToResult(on_error: local_on_error) { raise expected } == Failure(expected)
  end

  def test_local_on_error_overrides_global_nil
    setup_global_on_error

    FakeLogger.expects(:log_error).never

    local_on_error = nil

    expected = StandardError.new(@value)
    assert ToResult(on_error: local_on_error) { raise expected } == Failure(expected)
  end
end
