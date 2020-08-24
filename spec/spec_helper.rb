require 'simplecov'
require 'scrutinizer/ocular'
require "scrutinizer/ocular/formatter"
require "codeclimate-test-reporter"
require "sidekiq/testing"
require 'textris/delay/active_job/missing'
require 'textris/delay/sidekiq/missing'
require 'active_support/testing/time_helpers'

CodeClimate::TestReporter.configuration.logger = Logger.new("/dev/null")

if Scrutinizer::Ocular.should_run? ||
    CodeClimate::TestReporter.run? ||
    ENV["COVERAGE"]
  formatters = [SimpleCov::Formatter::HTMLFormatter]
  if Scrutinizer::Ocular.should_run?
    formatters << Scrutinizer::Ocular::UploadingFormatter
  end
  if CodeClimate::TestReporter.run?
    formatters << CodeClimate::TestReporter::Formatter
  end
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]

  CodeClimate::TestReporter.configuration.logger = nil

  SimpleCov.start do
    add_filter "/lib/textris.rb"
    add_filter "/spec/"
    add_filter "vendor"
  end
end

require_relative '../lib/textris'

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
