![rspec-sorbet](https://user-images.githubusercontent.com/2643026/63100456-02c12c00-bf6f-11e9-8430-630a27bc6e42.png)

# RSpec Sorbet [![Gem Version](https://badge.fury.io/rb/rspec-sorbet.svg)](https://badge.fury.io/rb/rspec-sorbet) ![CI Badge](https://github.com/tricycle/rspec-sorbet/workflows/Ruby/badge.svg)

A small gem consisting of helpers for using Sorbet & RSpec together.

## Install

`gem 'rspec-sorbet'`

## Usage

In your `spec_helper.rb` you need to first add a `require`:
```ruby
require 'rspec/sorbet'
```

### Allowing Instance/Class/Object Doubles

Out of the box if you're using `instance_double`, `class_double` or `object_double` in your tests you'll encounter errors such as the following:

```
 TypeError:
       Parameter 'my_parameter': Expected type MyObject, got type RSpec::Mocks::InstanceVerifyingDouble with value #<InstanceDouble(MyObject) (anonymous)>
       Caller: /Users/samuelgiles/Documents/Projects/Clients/Bellroy/bellroy/spec/lib/checkout/use_cases/my_use_case.rb:9
```

Drop the following into your `spec_helper.rb` to allow doubles to be used without breaking type checking:

```ruby
RSpec::Sorbet.allow_doubles!
```
