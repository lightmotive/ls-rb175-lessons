# frozen_string_literal: true

require 'sinatra/base'
require './view_helpers/application_helper'

module Controllers
  # Handle '/' route. All other controllers inherit this.
  class ApplicationController < Sinatra::Base
    def initialize
      super
      # rubocop:disable Style/ExpandPathArguments
      # - Reason: `File.expand_path(__dir__)` translates symbolic links to real
      #   paths, which we don't want in this program.
      @app_root_path = File.expand_path('../../', __FILE__)
      # rubocop:enable Style/ExpandPathArguments
    end

    helpers ViewHelpers::ApplicationHelper

    def app_root_path
      settings.app_root_path
    end

    configure do
      enable :sessions
      set :session_secret, 'd81b5e7a139eb9711a15d27c642ebe38e5457d86ad2d4d9c9f5df240e4d3ede8'
      set :erb, escape_html: true
      app_root_path = File.expand_path('..', __dir__)
      set :app_root_path, app_root_path
      set :public_folder, File.join(app_root_path, 'public')
      set :views, File.join(app_root_path, 'views')
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

    def content_path(child_path = '')
      File.join(app_root_path, 'content', child_path)
    end

    def content_entry_type(path)
      path = content_path(path)
      return :directory if FileTest.directory?(path)
      return :file if FileTest.file?(path)

      :unknown
    end

    # Build "view" `href` attribute value based on entry type:
    # - Use `/browse` route for directories.
    # - Use `/view` route for files.
    def content_entry_set_view_href!(entry)
      entry_path = File.join(entry[:directory], entry[:name])
      entry[:view_href] = case entry[:type]
                          when :directory then File.join('/', 'browse', entry_path)
                          when :file then File.join('/', 'view', entry_path)
                          end
      entry
    end

    # Build "edit" `href` attribute value based on entry type:
    # - Use `/edit` route for files.
    # - Disable for directories (assign `nil`).
    def content_entry_set_edit_href!(entry)
      entry_path = File.join(entry[:directory], entry[:name])
      entry[:edit_href] = case entry[:type]
                          when :directory then nil
                          when :file then File.join('/', 'edit', entry_path)
                          end
      entry
    end

    def content_entries(path_start = '')
      Dir.each_child(content_path(path_start)).map do |entry_path|
        entry = {
          directory: path_start.empty? ? '/' : path_start,
          name: entry_path,
          type: content_entry_type(File.join(path_start, entry_path))
        }
        content_entry_set_view_href!(entry)
        content_entry_set_edit_href!(entry)
      end
    end

    def validate_request_entry_path(path)
      # The web or app server handles this scenario automatically;
      # just in case (need to learn more):
      halt 404 if path.include?('..')
    end
  end
end
