require 'dry/monads'
require 'ostruct'

module ToResultMixin
  include Dry::Monads[:do, :result, :try]

  @@configuration = OpenStruct.new(
    on_error: nil
  )

  #
  # Allow to override the @@configuration fields
  #
  def self.configure
    yield @@configuration
  end

  #
  # ToResult executes a block of code and returns Success or Failure.
  # All exceptions inherited from StandardError are catched and
  # converted to Failure or you can pass a list of exceptions to catch.
  #
  # @param [Array<Class>] exceptions
  # @param [Proc] &f
  #
  # @return [Success]
  # @return [Failure]
  #
  def ToResult(exceptions = [StandardError], &f)
    Try.run(
      exceptions,
      Proc.new do
        f.call
      rescue Dry::Monads::Do::Halt => e
        error = e.result
        @@configuration.on_error.call(error) if @@configuration.on_error.respond_to?(:call)
        return error
      rescue *exceptions => e
        @@configuration.on_error.call(e) if @@configuration.on_error.respond_to?(:call)
        raise e
      end
    ).to_result
  end
end
