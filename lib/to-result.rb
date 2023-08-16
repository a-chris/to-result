require 'dry/monads'

module ToResultMixin
  include Dry::Monads[:do, :result, :try]

  class Configuration
    attr_accessor :on_error

    def on_error=(value)
      raise TypeError.new('on_error is expected to be a callable object') unless value.respond_to?(:call)

      @on_error = value
    end
  end

  @@configuration = Configuration.new

  #
  # Allow to override the @@configuration fields
  #
  def self.configure
    yield @@configuration
  end

  #
  # ToResult executes a block of code and returns Success or Failure.
  # All exceptions inherited from StandardError are catched and
  # converted to Failure or you can pass a custom list of exceptions
  # to catch using `only`.
  #
  # Passing the `on_error` block overrides the global on_error defined in to the Configuration,
  # it is possible to pass `nil` to not execute a block when an error is catched.
  #
  #
  # @param [Array<Class>] only is the array of Exception to catch
  # @param [Proc|Method] on_error is the function to be executed in case of error. It overrides the global on_error.
  # @param [Proc] &f is the block to run
  #
  # @return [Success]
  # @return [Failure]
  #
  def ToResult(only: [StandardError], **args, &f)
    # on_error included in args so we can distinguish when it's passed but it's nil
    # from when it's not passed at all
    on_error ||= args.key?(:on_error) ? args[:on_error] : @@configuration.on_error

    f_wrapper =
      Proc.new do
        f.call
      rescue Dry::Monads::Do::Halt => e
        failure = error = e.result
        error = error.failure if error.respond_to?(:failure)
        on_error.call(error) if on_error.respond_to?(:call)
        return failure
      rescue *only => e
        on_error.call(e) if on_error.respond_to?(:call)
        raise e
      end

    Try.run(only, f_wrapper).to_result
  end
end
