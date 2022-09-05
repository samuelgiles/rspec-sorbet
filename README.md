![rspec-sorbet](https://user-images.githubusercontent.com/2643026/63100456-02c12c00-bf6f-11e9-8430-630a27bc6e42.png)

# RSpec Sorbet [![Gem Version](https://badge.fury.io/rb/rspec-sorbet.svg)](https://badge.fury.io/rb/rspec-sorbet) ![CI Badge](https://github.com/tricycle/rspec-sorbet/workflows/Continuous%20Integration/badge.svg)

A small gem consisting of helpers for using Sorbet & RSpec together.

## Install

`gem 'rspec-sorbet'`

## Usage

In your `spec_helper.rb` you need to first add a `require`:
```ruby
require 'rspec/sorbet'
```

### Allowing Instance/Class/Object Doubles

Out of the box if you're using `instance_double`, `class_double` or `object_double` in your specs you'll encounter errors such as the following:

```
 TypeError:
       Parameter 'my_parameter': Expected type MyObject, got type RSpec::Mocks::InstanceVerifyingDouble with value #<InstanceDouble(MyObject) (anonymous)>
       Caller: /Users/samuelgiles/Documents/Projects/Clients/Bellroy/bellroy/spec/lib/checkout/use_cases/my_use_case.rb:9
```

Drop the following into your `spec_helper.rb` to allow doubles to be used without breaking type checking:

```ruby
RSpec::Sorbet.allow_doubles!
```

### `eq` matcher usage with `T::Struct`'s

Using the [`eq` matcher](https://www.rubydoc.info/github/rspec/rspec-expectations/RSpec%2FMatchers:eq) to compare [`T::Struct`'s](https://sorbet.org/docs/tstruct) might not behave as you'd expect whereby two separate instances of the same struct class with identical attributes are not `==` out of the box. The standalone [sorbet-struct-comparable](https://github.com/tricycle/sorbet-struct-comparable) gem may be of interest if you are looking for a simple attribute based comparison that will help make the `eq` matcher behave as you expect.

### Specifying a custom validation handler

You can customise the handler of Sorbet validation errors if you so desire.


```ruby
def handler(signature, opts)
  raise MyCustomException, "The options were #{opts}"
end

T::Configuration.call_validation_error_handler = handler
```
