
# ToResult

ToResult is a wrapper built over `dry-monads` to make the `Do Notation`, `Result` and `Try` concepts more handy and consistent to use, in particular to implement the **Railway Pattern**.

## Why I created ToResult

`dry-monads` is full of edge cases that requires to write boilerplate code everytime I want a method to return a `Success` or `Failure`, for example:

```ruby
def my_method
  Success(another_method.call)
rescue StandardError => e
  Failure(e)
end
```

so I started using `Try`, that makes the code easier to read and faster to write:
```ruby
def my_method
  Try do
    another_method.call
  end.to_result
end
```

but I feel like `to_result` is not really visible at the end of the code and if you forget to write it (as always happens to me) your application blows up.

But this is not the bigget problem, bear with me.

One of the biggest problem is that we cannot use the `Do Notation` inside a `Try` block:
```ruby
def my_method
  Try do
    # this will raise a Dry::Monads::Do::Halt exception
    yield Failure('error code')
  end.to_result
end
```

and you cannot even use `yield` and `rescue` in the same method:

```ruby
def my_method
  # this will raise a Dry::Monads::Do::Halt exception
  yield Failure('error code')
rescue StandardError => e
  # e is an instance of Dry::Monads::Do::Halt
  Failure(e)
end
```

because they will raise a `Dry::Monads::Do::Halt` exception and the original exception will be forever lost if we do not "unbox" the exception with `e.result`.

## Usage

To use it with instances of a class, just include it
```ruby
class MyClass
  include ToResultMixin

  def my_method
    ToResult do
      whatever_method.call
    end
  end
end
```

or if you want to use it with Singleton Classes:
```ruby
class MyClass
  extend ToResultMixin

  class << self
    def my_method
      ToResult do
        whatever_method.call
      end
    end
  end
end
```

now you can always use `ToResult` all the time you wanted to use `Success`, `Failure` or `Try` but with a more handy interface and consistent behaviour.

Look at this:

```ruby
ToResult { raise StandardError.new('error code') }
# returns Failure(StandardError('error code'))

ToResult { yield Success('hello!') }
# returns Success('hello!')

ToResult { yield Failure('error code') }
# returns Failure('error code')

ToResult { yield Failure(StandardError.new('error code')) }
# returns Failure(StandardError('error code'))
```

## Roadmap
I'm already planning to implement some useful features:
- [ ] configurable error logging when an exception is catched inside `DoResult`
e.g. sending the log to Airbrake or whathever service you are using
- [ ] write more examples/documentation/tests
- [ ] any other suggestion would be appreciated 😁

## Authors

- [@a-chris](https://www.github.com/a-chris)
