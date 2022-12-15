# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle browse routes
  class BrowseController < ApplicationController
    helpers do
      def navigation_path(current_location = '/')
        return '' if current_location == '/'

        href = APP_ROUTES[:browse]
        nav_path = "<a href=\"#{href}\">home</a>"

        dir_names = current_location[1..].split('/')
        dir_names[0..-2].each do |name|
          href += "/#{name}"
          nav_path += "/<a href=\"#{href}\">#{name}</a>"
        end

        nav_path += "/#{dir_names.last}"
        nav_path
      end
    end

    # get 'APP_ROUTES[:browse]/*'
    # Get public content entries starting at current_location and render :browse if
    # :directory or redirect to view file if :file
    get '/*' do
      case content_entry_type(current_location)
      when :directory
        @entries = content_entries(current_location)
        erb :browse
      when :file
        redirect URLUtils.join_components(APP_ROUTES[:view], current_location)
      else
        content_missing(current_location)
      end
    end
  end
end
