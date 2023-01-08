# frozen_string_literal: true

require_relative 'application_controller'
require './models/content_entry'

module Controllers
  # Create new file system entries.
  class RenameEntryController < ApplicationController
    attr_reader :entry_name, :entry

    before '*' do
      @entry_name = params[:entry_name]

      handle_init_error('The request requires an `entry_name` param.') if @entry_name.nil?

      unless content_entry_type_supported?(name: @entry_name, in_loc: current_location)
        handle_init_error("That entry wasn't found. Please check and try again.")
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
        halt 400, handle_input_error
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
        handle_input_error
      end
    end

    private

    def handle_init_error(message)
      flash_message :error, message

      if request.xhr?
        halt 400, render_flash_messages
      else
        redirect app_route(:browse, loc: current_location)
      end
    end

    def handle_input_error
      status 400
      if request.xhr?
        render_flash_messages
      else
        erb :content_entry_rename_page
      end
    end
  end
end
