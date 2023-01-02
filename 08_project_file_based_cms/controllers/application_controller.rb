# frozen_string_literal: true

require 'sinatra/base'
require 'forwardable'
require 'uri'
require './cms_app_helper'

module Controllers
  # Handle '/' route. All other controllers inherit this.
  class ApplicationController < Sinatra::Base
    extend Forwardable
    include CMSAppHelper

    def initialize
      super
      @content = Models::Content.new
      self.title = ''
      @current_location = nil
    end

    attr_reader :title, :current_location, :current_location_entry_type

    def title=(value)
      @title = "#{value.empty? ? '' : "#{value} - "}Neato CMS"
    end

    def_delegators :@content, :create_file, :create_directory
    def_delegator :@content, :path, :content_path
    def_delegator :@content, :entry_type, :content_entry_type
    def_delegator :@content, :directory?, :content_directory?
    def_delegator :@content, :file?, :content_file?
    def_delegator :@content, :entries, :content_entries

    helpers Sinatra::ContentFor, ViewHelpers::App

    configure do
      enable :sessions
      set :session_secret, 'd81b5e7a139eb9711a15d27c642ebe38e5457d86ad2d4d9c9f5df240e4d3ede8'
      set :erb, escape_html: true, layout_engine: :erubi
      content = Models::Content.new
      set :public_folder, File.join(content.app_root_path, 'public')
      set :views, File.join(content.app_root_path, 'views')
    end

    def flash_message(flash_key, content)
      ViewHelpers::App.flash_message(flash_key, content, store: session)
    end

    # Apply location ("loc" query param) to request.
    # This param is available to use with most requests.
    def validate_and_set_location
      location = params[:loc]
      params.delete(:loc)
      return halt(400, 'Invalid location') if location&.include?('..')

      @current_location = location.nil? || location.empty? ? '/' : location
      self.title = current_location unless current_location == '/'
      @current_location
    end

    # before {all routes}
    before '*' do
      validate_and_set_location
      check_authentication
      verify_location_exists(@current_location)
    end

    get '/' do
      return redirect app_route(:browse) if authenticated?

      erb :index
    end

    not_found do
      redirect app_route(:browse) if authenticated?
      redirect app_route(:index)
    end

    def username
      session[:username]
    end

    private

    attr_writer :current_location_entry_type

    def authenticated?
      !!session[:username]
    end

    # Redirect to login route if appropriate
    def check_authentication
      return if authenticated? || route_public?(request_script_name_standardized)

      session[:post_auth_location] = app_route(APP_ROUTES.key(request.env['SCRIPT_NAME']), loc: @current_location)
      flash_message(:info, 'Please sign in to access that resource.')
      redirect app_route(:login)
    end

    def authenticate(username, password)
      return unless Models::Authenticator.new({ username:, password: }).valid?

      session[:username] = username
    end

    def logout
      flash_message :success, 'You have been signed out.'
      session.delete(:username)
      redirect app_route(:index)
    end

    def redirect_after_auth
      location = session.delete(:post_auth_location)
      flash_message :success, 'Welcome!' if location.nil? || location == app_route(:index)

      return redirect app_route(:browse) if location.nil?

      redirect location
    end

    # Redirect if location doesn't exist.
    def verify_location_exists(location)
      self.current_location_entry_type = content_entry_type(location)
      return unless current_location_entry_type == :unknown

      flash_message :error, 'That location does not exist. Please browse and try again.'
      not_found
    end
  end
end
