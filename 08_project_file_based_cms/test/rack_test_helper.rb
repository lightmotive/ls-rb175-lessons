# frozen_string_literal: true

require_relative 'auth_test_helper'
require_relative 'test_helper'
require 'rack/test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first
