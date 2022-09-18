require 'dry/monads'

module ToResultMixin
  include Dry::Monads[:do, :result, :try]

  def ToResult(exceptions = [StandardError], &f)
    Dry::Monads::Try.run(
      [StandardError],
      Proc.new do
        f.call
      rescue Dry::Monads::Do::Halt => e
        return e.result
      rescue StandardError => e
        raise e
      end
    ).to_result
  end
end
