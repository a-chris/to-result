class FakeLogger
  def self.log_error
    true
  end

  def self.return_error(e)
    e
  end
end
