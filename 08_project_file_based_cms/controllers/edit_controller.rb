# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle '/edit' routes.
  class EditController < ApplicationController
    def validate_edit_path(path)
      validate_request_entry_path(path)

      case content_entry_type(path)
      when :file
        path
      when :directory
        session[:error] = 'Editing not allowed.'
        redirect File.join('/browse', path)
      else
        # :nocov:
        redirect '/browse'
        # :nocov:
      end
    end

    # before '/edit/*'
    before '/*' do
      @edit_path = params['splat'].first
      validate_edit_path(@edit_path)
    end

    # Edit files
    # get '/edit/*'
    get '/*' do
      local_file_path = content_path(@edit_path)
      @file_content = File.read(local_file_path)
      erb :edit
    end

    # Save submitted content to file, then redirect to file's directory.
    # post '/edit/*'
    post '/*' do
      file_content = params[:file_content]
      local_file_path = content_path(@edit_path)
      File.write(local_file_path, file_content)

      session[:success] = "#{File.basename(@edit_path)} has been updated."
      redirect File.join('/browse', File.dirname(@edit_path)), 303
    end
  end
end
