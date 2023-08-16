class FakeLogger
  def self.log_error(e)
    e
  end

  def self.return_error(e)
    e
  end
end
