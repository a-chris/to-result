
# ToResult

ToResult is a wrapper built over `dry-monads` to make the `Do Notation`, `Result` and `Try` concepts more handy and consistent to use, in particular to implement the **Railway Pattern**.

## Why I created ToResult

`dry-monads` requires to write boilerplate code everytime we want a method to return a `Success` or `Failure`, for example:

```ruby
def my_method
  Success(another_method.call)
rescue StandardError => e
  Failure(e)
end
```

yes, we can use `Try` which makes the code easier to read and faster to write:
```ruby
def my_method
  Try do
    another_method.call
  end.to_result
end
```

but I feel like `to_result` is not really visible at the end of the block and if you forget to write it (as always happens to me) your application blows up.

But this is not the biggest problem, bear with me.

One of the biggest problem is that we cannot use the **Do Notation** inside a `Try` block:
```ruby
# this will return a Failure(Dry::Monads::Do::Halt)
def my_method
  Try do
    yield Failure('error code')
  end.to_result
end
```

and you cannot even use `yield` and `rescue` in the same method:

```ruby
# this will return a Failure(Dry::Monads::Do::Halt)
def my_method
  yield Failure('error code')
rescue StandardError => e
  # e is an instance of Dry::Monads::Do::Halt
  Failure(e)
end
```

because they will raise a `Dry::Monads::Do::Halt` exception and the original error will be forever lost if we do not "unbox" the exception with `e.result` like this:

```ruby
def my_method
  yield Failure('error code')
rescue Dry::Monads::Do::Halt => e
  return e.result
rescue StandardError => e
  Failure(e)
end
```

to be honest this is an implementation detail I don't want to care about while I'm writing my business logic and as far as I've seen this is really hard for junior developers to figure out what is happening with `Do::Halt`.

With this gem, `to-result`, that piece of code can be written as:
```ruby
def my_method
  ToResult do
    yield Failure('error code')
  end
end
```

and it will return `Failure('error code')` without all the effort to think about `Do::Halt`. Moreover, you can keep using `ToResult` everytime you could have used `Try` or monads in general, so you have just **one way** to write monads in your code.

## Installation

To install with bundler:
```bash
bundle add to-result
```
or with `gem`:
```bash
gem install to-result
```

## Usage

To use it with instances of a class, just include it
```ruby
require 'to_result'

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
require 'to_result'

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

now you can always use `ToResult` all the time you wanted to use `Success`, `Failure` or `Try` but with a more convenient interface and consistent behaviour.

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

ToResult(only: [YourCustomError]) { yield Failure(YourCustomError.new('error code')) }
# returns Failure(YourCustomError('error code'))

ToResult(only: [ArgumentError]) { yield Failure(YourCustomError.new('error code')) }
# raises YourCustomError('error code')
```

## Local and global callback on errors
to-result gives you the possibility to define a callback to be called when an error is raised inside the `ToResult` block, this is a handy place to log errors.

You can define a global callback, usually defined into an initializer:

```
# initializers/to_result.rb

ToResultMixin.configure do |c|
  c.on_error = Proc.new { |e| Logger.log_error(e) }
end
```

or a local callback:

```
ToResult(on_error: { |e| Logger.log_error(e) }) do
  yield Failure(StandardError.new('error code'))
end
```

you can even use both at the same time but keep in mind that **local callback overrides the global one**.


## Changelog

[Changelog](CHANGELOG.md)

## Roadmap
I'm already planning to implement some useful features:
- [x] write more examples/documentation/tests
- [x] configurable error logging when an exception is catched inside `DoResult`
e.g. sending the log to Airbrake or whathever service you are using
- [x] transform/process the catched error => this can be handled with `alt_map` or other methods already available in `dry-monads`
- [ ] any type of suggestion is appreciated 😁

## Authors

- [@a-chris](https://www.github.com/a-chris)
