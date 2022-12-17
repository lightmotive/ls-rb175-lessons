# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle 'app_route(:delete)' routes.
  class DeleteController < ApplicationController
    # Save submitted content to file, then redirect to file's directory.
    # post 'app_route(:delete)/'
    post '/' do
      content = Models::Content.new
      content.delete_entry(current_location)

      if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
        status 204
      else
        flash_success_message "#{File.basename(current_location)} was deleted."
        redirect app_route(:browse, loc: File.dirname(current_location)), 303
      end
    end
  end
end
