# frozen_string_literal: true

require_relative 'application_controller'
require './models/content'

module Controllers
  # Upload file(s)
  class UploadController < ApplicationController
    # Upload file using `file`-type input.
    # post 'app_route(:upload)/'
    post '/' do
      return unless params[:uploads]

      validate_and_save_uploads(params[:uploads])
      redirect app_route(:browse, loc: current_location)
    end

    def validate_and_save_uploads(uploads)
      saved_filenames = []
      uploads.each do |upload|
        error = upload_error(upload)
        next flash_message(:error, error) unless error.nil?

        save_upload(upload)
        saved_filenames << upload[:filename]
      end

      flash_saved_filenames(saved_filenames)
    end

    def upload_error(upload)
      # TODO: consider implementing polymorphic sequence processing here to
      # iterate through validation steps defined in separate classes.
      # Recommended only if file validation becomes complex enough to warrant
      # step and step iteration encapsulation.
      errors = []

      unless Models::ContentEntry.file_name_allowed?(upload[:filename])
        errors << Models::ContentEntry.entry_name_chars_allowed_message
      end

      unless Models::ContentEntry.content_type_allowed?(upload[:type])
        errors << Models::ContentEntry.file_types_allowed_message
      end

      return "'#{upload[:filename]}' was not allowed. #{errors.join(' ')}" unless errors.empty?

      nil
    end

    def save_upload(upload)
      from_path = upload[:tempfile].path
      to_path = File.join(current_location, upload[:filename])
      Models::Content.new.copy_external(from_path, to_path)
    end

    def flash_saved_filenames(saved_filenames)
      return if saved_filenames.empty?

      filenames_list = saved_filenames.map { |name| "'#{name}'" }
      filenames_list[-1] = "and #{filenames_list[-1]}" if filenames_list.size > 1
      list_separator = filenames_list.size > 2 ? ', ' : ' '

      message = "Successfully uploaded #{filenames_list.join(list_separator)}."
      flash_message(:success, message)
    end
  end
end
