require 'dry/monads'

module ToResultMixin
  include Dry::Monads[:do, :result, :try]

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
        return e.result
      rescue *exceptions => e
        raise e
      end
    ).to_result
  end
end
