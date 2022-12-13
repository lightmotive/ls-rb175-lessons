# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle 'APP_ROUTES[:edit]' routes.
  class EditController < ApplicationController
    def validate_edit_path(path)
      validate_request_entry_path(path)

      case content_entry_type(path)
      when :file
        path
      when :directory
        session[:error] = 'Editing not allowed.'
        redirect File.join(APP_ROUTES[:browse], path)
      else
        # :nocov:
        redirect APP_ROUTES[:browse]
        # :nocov:
      end
    end

    # before 'APP_ROUTES[:edit]/*'
    before '/*' do
      @edit_path = params['splat'].first
      validate_edit_path(@edit_path)
    end

    # Edit files
    # get 'APP_ROUTES[:edit]/*'
    get '/*' do
      file_path = content_path(@edit_path)
      @file_content = File.read(file_path)
      erb :edit
    end

    # Save submitted content to file, then redirect to file's directory.
    # post 'APP_ROUTES[:edit]/*'
    post '/*' do
      file_content = params[:file_content]
      file_path = content_path(@edit_path)
      File.write(file_path, file_content)

      session[:success] = "#{File.basename(@edit_path)} has been updated."
      redirect File.join(APP_ROUTES[:browse], File.dirname(@edit_path)), 303
    end
  end
end
