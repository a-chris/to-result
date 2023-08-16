require 'byebug'

require './lib/to-result'
require './spec/support/fake_object'


RSpec.describe ToResultMixin do
  include ToResultMixin

  let(:value) { 'hello world!' }

  before do
    # reset the configuration before each test
    ToResultMixin.configure { |c| c = {} }
  end

  describe 'result handling' do
    it 'returns a Success with the value of the block' do
      expect(ToResult { value }).to eq(Success(value))
    end

    it 'returns a Success without the Success of the block' do
      expected = Success(value)
      expect(ToResult { expected }).to eq(Success(expected))
    end

    it 'returns a Failure with the exception raised by the block' do
      expected = StandardError.new(value)
      expect(ToResult { raise expected }).to eq(Failure(expected))
    end

    it 'returns a Failure if the error class is included in `only`' do
      expected = ArgumentError.new(value)
      expect(ToResult(only: [ArgumentError]) { raise expected }).to eq(Failure(expected))
    end

    it 'raises an error if the error class is not included in `only`' do
      expected = NameError.new(value)
      expect { ToResult(only: [ArgumentError]) { raise expected } }.to raise_error(NameError)
    end

    it 'returns Failure if the block raises a Dry::Monads::Do::Halt error' do
      expected = Dry::Monads::Failure(StandardError.new(value))
      # it equals to ToResult { yield expected }
      expect(FakeObject.raise_do_halt_error(expected)).to eq(expected)
    end
  end

  describe 'on_error' do
    it 'passes the unwrapped error to on_error' do
      local_on_error = proc { |e| FakeObject.log_error(e) }

      expected  = StandardError.new(value)
      failure   = Failure(expected)
      expect(FakeObject).to receive(:log_error).and_return(expected).once
      # it equals to ToResult { yield expected }
      expect(FakeObject.raise_do_halt_error(failure, on_error: local_on_error)).to eq(Dry::Monads::Failure.new(expected))
    end

    context 'when gloval callback is not defiend' do
      it 'uses the local on_error' do
        local_on_error = proc { |e| FakeObject.log_error(e) }

        expected = StandardError.new(value)
        expect(FakeObject).to receive(:log_error).and_return(expected).once
        expect(ToResult(on_error: local_on_error) { raise expected }).to eq(Failure(expected))
      end

      it 'does not raise error if local on_error is not a proc' do
        local_on_error = 'not a proc'

        expected = StandardError.new(value)
        FakeObject.methods(false).each { |m| expect(FakeObject).to receive(m).never }
        expect(ToResult(on_error: local_on_error) { raise expected }).to eq(Failure(expected))
      end
    end

    context 'when global callback is invalid' do
      it 'raises an error' do
        expect do
          ToResultMixin.configure { |c| c.on_error = 'invalid value, should be a proc' }
        end.to raise_error(TypeError)
      end
    end

    context 'when global callback if valid and defined globally' do
      before do
        ToResultMixin.configure do |c|
          c.on_error = proc { |e| FakeObject.log_error(e) }
        end
      end

      it 'calls the global callback' do
        expected = StandardError.new(value)
        expect(FakeObject).to receive(:log_error).with(expected).once
        expect(ToResult { raise expected }).to eq(Failure(expected))
      end

      it 'uses local on_error over the global one' do
        local_on_error = Proc.new { |e| FakeObject.log_error_copy(e) }

        expected = StandardError.new(value)
        expect(FakeObject).to receive(:log_error_copy).with(expected).once
        expect(ToResult(on_error: local_on_error) { raise expected }).to eq(Failure(expected))
      end

      it 'uses local on_error over the global one even if nil' do
        local_on_error = nil

        expected = StandardError.new(value)
        FakeObject.methods(false).each { |m| expect(FakeObject).to receive(m).never }
        expect(ToResult(on_error: local_on_error) { raise expected }).to eq(Failure(expected))
      end
    end
  end
end
