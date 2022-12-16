# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle browse routes
  class BrowseController < ApplicationController
    def initialize
      super
      @new_directory_href = nil
      @new_file_href = nil
    end

    attr_reader :new_directory_href, :new_file_href

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
        enable_new_entries
        erb :browse
      when :file
        redirect URLUtils.join_components(APP_ROUTES[:view], current_location)
      else
        content_missing(current_location)
      end
    end

    def enable_new_entries
      @new_directory_href = URLUtils.join_components(APP_ROUTES[:new_dir], current_location)
      @new_file_href = URLUtils.join_components(APP_ROUTES[:new_file], current_location)
    end
  end
end
