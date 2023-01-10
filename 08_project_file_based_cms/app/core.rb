# frozen_string_literal: true

require 'uri'

def test?
  ENV['RACK_ENV'] == 'test'
end

def development?
  ENV['RACK_ENV'] == 'development'
end

require_relative 'app_routes'
