# RSpec Sorbet

A small gem consisting of helpers for using Sorbet & RSpec together.

## Install

`gem 'rspec-sorbet'`

## Usage

In your `spec_helper.rb` you need to first add a `require`:
```ruby
require 'rspec/sorbet'
```

### Allowing Instance Doubles

Out of the box if your using `instance_double`'s in your tests you'll encounter errors such as the following:

```
 TypeError:
       Parameter 'my_parameter': Expected type MyObject, got type RSpec::Mocks::InstanceVerifyingDouble with value #<InstanceDouble(MyObject) (anonymous)>
       Caller: /Users/samuelgiles/Documents/Projects/Clients/Bellroy/bellroy/spec/lib/checkout/use_cases/my_use_case.rb:9
```

Drop the following into your `spec_helper.rb` to allow instance doubles to be used:

```ruby
RSpec::Sorbet.allow_instance_doubles!
```
