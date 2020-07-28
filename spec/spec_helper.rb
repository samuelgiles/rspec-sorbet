# typed: strict
# frozen_string_literal: true

if !ENV['METRICS'].nil? || !ENV['COVERAGE'].nil?
  require 'simplecov'
  SimpleCov.at_exit do
    SimpleCov.result.format!
  end
  SimpleCov.start
end

require 'pry'
require 'bundler/setup'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  RSpec::Expectations.configuration.on_potential_false_positives = :nothing
  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
