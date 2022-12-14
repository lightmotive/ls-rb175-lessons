# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle 'app_route(:delete)' routes.
  class DeleteController < ApplicationController
    # Delete specified entry, then redirect to the entry's parent directory.
    # post 'app_route(:delete)/'
    post '/' do
      content = Models::Content.new
      content.delete_entry(current_location)

      if request.xhr? # env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
        status 204
      else
        flash_message :success, "#{File.basename(current_location)} was deleted."
        redirect app_route(:browse, loc: File.dirname(current_location)), 303
      end
    end
  end
end
