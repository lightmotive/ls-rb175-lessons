# frozen_string_literal: true

require 'sinatra/base'
require 'forwardable'
require './view_helpers/application_helper'

module Controllers
  # Handle '/' route. All other controllers inherit this.
  class ApplicationController < Sinatra::Base
    extend Forwardable

    def initialize
      super
      @app_content = ApplicationContent.new
    end

    def_delegators :@app_content, :content_path, :content_entry_type,
                   :content_entries

    helpers ViewHelpers::ApplicationHelper

    configure do
      enable :sessions
      set :session_secret, 'd81b5e7a139eb9711a15d27c642ebe38e5457d86ad2d4d9c9f5df240e4d3ede8'
      set :erb, escape_html: true
      app_content = Controllers::ApplicationContent.new
      set :public_folder, File.join(app_content.app_root_path, 'public')
      set :views, File.join(app_content.app_root_path, 'views')
    end

    get '/' do
      redirect '/browse'
    end

    not_found do
      redirect '/browse'
    end

    def content_missing(missing_path)
      session[:error] = "#{File.join('/', missing_path)} wasn't found."
      redirect '/browse'
    end

    def validate_request_entry_path(path)
      # The web or app server handles this scenario automatically;
      # just in case (need to learn more):
      halt 404 if path.include?('..')
    end
  end
end
