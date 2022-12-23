# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

# TODO: set the following env vars using environment management systems:
# - For dev and test: https://github.com/bkeepers/dotenv
# - For production, use host framework's secure environment management system.
ENV['TEST_USER_ADMIN'] = 'test-user-admin-DKI1b!zBDsR+F' if ENV['RACK_ENV'] == 'test'
ENV['TEST_USER_OTHER'] = 'test-user-other-DKI1b!zBDsR+F' if ENV['RACK_ENV'] == 'test'

def test_authenticated?(session)
  test_auth_value = ENV.fetch('TEST_USER_ADMIN', nil)
  return false if test_auth_value.nil?

  session[:username] == test_auth_value
end

require_relative 'test_helper'
require 'rack/test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first
