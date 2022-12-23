# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle 'app_route(:login)' routes.
  class LogoutController < ApplicationController
    post '/' do
      logout
    end
  end
end
