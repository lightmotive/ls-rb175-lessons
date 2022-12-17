# frozen_string_literal: true

require_relative 'application_controller'
require 'redcarpet'

module Controllers
  # Handle 'APP_ROUTES[:view]' routes.
  class ViewController < ApplicationController
    def initialize
      super

      @custom_file_content = nil
    end

    attr_accessor :custom_file_content

    # TODO: Refactor to class with separate classes mapped for each file type.
    def custom_file_renderers
      {
        '.md' => { response_content_type: :html,
                   render: lambda do |file_path_absolute|
                     markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
                     self.custom_file_content = markdown.render(File.read(file_path_absolute))
                     erb :file_html, layout: :layout_file_html
                   end }
      }
    end

    def view_file_response(file_path_relative)
      file_path = content_path(file_path_relative)
      self.title = "#{file_path_relative} - #{@title}"

      custom_renderer = custom_file_renderers[File.extname(file_path)]
      if custom_renderer
        content_type custom_renderer[:response_content_type]
        custom_renderer[:render].call(file_path)
      else
        send_file file_path
      end
    end

    # View files (`send_file` or custom processing)
    # get 'APP_ROUTES[:view]/*'
    get '/*' do
      case content_entry_type(current_location)
      when :file
        view_file_response(current_location)
      when :directory then redirect_to_current_location
      else
        content_missing(current_location)
      end
    end
  end
end
