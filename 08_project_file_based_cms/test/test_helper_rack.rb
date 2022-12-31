# frozen_string_literal: true

require_relative 'test_helper'
require './test/auth/helpers'
Test::Auth::Helpers::TempUsers.create
# Rakefile invokes `Test::Auth::Helpers::TempUsers.destroy` after :test task

require 'rack/test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first
