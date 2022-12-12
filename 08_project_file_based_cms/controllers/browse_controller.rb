# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle '/browse' routes
  class BrowseController < ApplicationController
    helpers do
      def navigation_path(browse_path)
        return '' if browse_path == '/'

        href = '/browse'
        nav_path = "<a href=\"#{href}\">home</a>"

        dir_names = browse_path.split('/')
        dir_names[0..-2].each do |name|
          href += "/#{name}"
          nav_path += "/<a href=\"#{href}\">#{name}</a>"
        end

        nav_path += "/#{dir_names.last}"
        nav_path
      end
    end

    # get '/browse'
    get '/' do
      @browse_path = '/'
      @entries = content_entries

      erb :browse
    end

    # get '/browse/*'
    # Get public content entries starting at browse_path and render :browse if
    # :directory or redirect to view file if :file
    get '/*' do
      @browse_path = params['splat'].first
      validate_request_entry_path(@browse_path)

      case content_entry_type(@browse_path)
      when :directory
        @entries = content_entries(@browse_path)
        erb :browse
      when :file
        redirect File.join('/', 'view', @browse_path)
      else
        content_missing(@browse_path)
      end
    end
  end
end
