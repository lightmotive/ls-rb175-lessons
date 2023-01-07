# frozen_string_literal: true

require_relative 'browse_controller'
require './models/content_entry'

module Controllers
  # Create new file system entries.
  class RenameEntryController < BrowseController
    attr_reader :entry_name, :entry

    before '*' do
      @entry_name = params[:entry_name]

      if @entry_name.nil?
        flash_message :error, 'The request requires an `entry_name` param.'
        halt 400, render_browse_template
      end

      unless content_entry_type_supported?(name: @entry_name, in_loc: current_location)
        flash_message :error, "That entry wasn't found. Please check and try again."
        halt 400, render_browse_template
      end

      @entry = content_entry(name: entry_name, in_loc: current_location)
    end

    helpers do
      def render_content_entry_rename_component
        ViewHelpers::ContentEntryRenameComponent.new(
          entry, loc: current_location, params:
        ).render
      end
    end

    # get 'app_route(:rename_entry)/'
    get '/' do
      if request.xhr?
        render_content_entry_rename_component
      else
        erb :content_entry_rename_page
      end
    end

    # post 'app_route(:rename_entry)/'
    post '/' do
      entry_name_new = params[:entry_name_new]

      if entry_name_new.nil?
        flash_message :error, 'The request requires an `entry_name_new` param.'
        halt 400, post_error_body
      end

      begin
        rename_entry(entry.name, entry_name_new, in_loc: current_location)
        flash_message :success, "'#{entry.name}' renamed to '#{entry_name_new}'."
        redirect_url = app_route(:browse, loc: current_location)
        if request.xhr?
          redirect_url
        else
          redirect redirect_url, 303
        end
      rescue Models::ContentError => e
        flash_message :error, e.messages
        post_error_body
      end
    end

    private

    def post_error_body
      status 400
      if request.xhr?
        render_flash_messages
      else
        erb :content_entry_rename_page
      end
    end
  end
end
