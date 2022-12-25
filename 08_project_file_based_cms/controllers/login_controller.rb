# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle 'app_route(:login)' routes.
  class LoginController < ApplicationController
    def title
      "Log in - #{super}"
    end

    # Display login page
    # get 'app_route(:login)/'
    get '/' do
      return redirect app_route(:browse) if authenticated?

      erb :login
    end

    # Log in user
    # post 'app_route(:login)/'
    post '/' do
      authenticate(params[:username], params[:password])

      if authenticated?
        redirect_after_auth
      else
        flash_message :error, 'Invalid credentials. Please check your username and password.'
        erb :login
      end
    end
  end
end
