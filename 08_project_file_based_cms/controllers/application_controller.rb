# frozen_string_literal: true

require 'sinatra/base'
require 'forwardable'

module Controllers
  # Handle '/' route. All other controllers inherit this.
  class ApplicationController < Sinatra::Base
    extend Forwardable

    def initialize
      super
      @content = Models::Content.new
    end

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
      redirect APP_ROUTES[:browse]
    end

    not_found do
      redirect APP_ROUTES[:browse]
    end

    def content_missing(missing_path)
      session[:error] = "#{URLUtils.join_components('/', missing_path)} wasn't found."
      redirect APP_ROUTES[:browse]
    end

    def validate_request_entry_path(path)
      # The web or app server handles this scenario automatically;
      # just in case (need to learn more):
      halt 404 if path.include?('..')
    end
  end
end
