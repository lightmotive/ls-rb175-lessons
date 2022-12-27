# frozen_string_literal: true

require './cms_app_helper'

# TODO: set the following env vars using environment management systems:
# - For dev and test: https://github.com/bkeepers/dotenv
# - For production, use host framework's secure environment management system.
ENV['RACK_ENV'] = 'test'

require './auth/test_helpers'
Auth::TestHelpers::TempUsers.create
# Rakefile invokes `Auth::TestHelpers::TempUsers.destroy` after :test task

require_relative 'test_helper'
require 'rack/test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first
