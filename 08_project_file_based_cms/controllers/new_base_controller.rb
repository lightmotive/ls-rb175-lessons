# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Base controller for creating new file system entries
  class NewBaseController < ApplicationController
    def initialize
      super

      @type = nil
    end

    attr_reader :type

    helpers do
      def post_route
        case type
        when :dir then app_route(:new_dir, current_location)
        when :file then app_route(:new_file, current_location)
        end
      end

      def type_name
        case type
        when :dir then 'directory'
        when :file then 'file'
        end
      end

      def allowed_input_message
        Models::ContentEntry.entry_name_chars_allowed_message
      end
    end
  end
end
