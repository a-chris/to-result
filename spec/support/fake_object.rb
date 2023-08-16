class FakeObject
  extend ToResultMixin

  def self.log_error(e)
    e
  end

  def self.log_error_copy(e)
    e
  end

  def self.raise_do_halt_error(failure, on_error: nil)
    ToResult(on_error: on_error) { yield failure }
  end
end
