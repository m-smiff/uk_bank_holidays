# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'uk_bank_holidays'

require 'httparty'
require 'json'
require 'rspec/collection_matchers'
require 'timecop'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
