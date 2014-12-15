require 'simplecov'
require 'scrutinizer/ocular'

Scrutinizer::Ocular.watch!

if Scrutinizer::Ocular.should_run? || ENV["COVERAGE"]
  if Scrutinizer::Ocular.should_run?
    SimpleCov.formatter = Scrutinizer::Ocular::UploadFormatter
  end

  SimpleCov.start do
    add_filter "/spec/"
  end
end

require_relative '../lib/textris'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
