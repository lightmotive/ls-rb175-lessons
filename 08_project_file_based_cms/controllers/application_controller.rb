# frozen_string_literal: true

require 'sinatra/base'
require 'forwardable'
require 'uri'

module Controllers
  # Handle '/' route. All other controllers inherit this.
  class ApplicationController < Sinatra::Base
    extend Forwardable

    def initialize
      super
      @content = Models::Content.new
      @title = 'Neato CMS'
      @current_location = nil
    end

    attr_accessor :title
    attr_reader :current_location, :current_location_entry_type

    def_delegator :@content, :path, :content_path
    def_delegator :@content, :entry_type, :content_entry_type
    def_delegator :@content, :entries, :content_entries

    helpers ViewHelpers::ApplicationHelper

    configure do
      enable :sessions
      set :session_secret, 'd81b5e7a139eb9711a15d27c642ebe38e5457d86ad2d4d9c9f5df240e4d3ede8'
      set :erb, escape_html: true
      content = Models::Content.new
      set :public_folder, File.join(content.app_root_path, 'public')
      set :views, File.join(content.app_root_path, 'views')
    end

    get '/' do
      redirect app_route(:browse)
    end

    not_found do
      redirect app_route(:browse)
    end

    def flash_error_message(message)
      session[:error] = message
    end

    def flash_success_message(message)
      session[:success] = message
    end

    def authenticated?
      !!session[:username]
    end

    # before {all routes}
    before '/' do
      # Apply global query parameters
      location = params[:loc]
      halt 404 if location&.include?('..')
      @current_location = location.nil? || location.empty? ? '/' : location

      # # Check signed-in status
      # redirect app_route(:login, loc: @current_location) unless session[:username]

      verify_location_exists(@current_location)
    end

    private

    attr_writer :current_location_entry_type

    # Redirect if it doesn't exist
    def verify_location_exists(location)
      type = content_entry_type(location)
      if %i[file directory].include?(type)
        self.current_location_entry_type = type
      else
        flash_error_message 'Entry not found.'
        redirect app_route(:browse)
      end
    end
  end
end
