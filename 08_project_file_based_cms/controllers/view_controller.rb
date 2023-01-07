# frozen_string_literal: true

require_relative 'application_controller'
require 'redcarpet'

module Controllers
  # Handle 'app_route(:view)' routes.
  class ViewController < ApplicationController
    def initialize
      super

      @custom_file_content = nil
    end

    def title
      "View #{super}"
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
      file_path = content_absolute_path(file_path_relative)

      custom_renderer = custom_file_renderers[File.extname(file_path)]
      if custom_renderer
        content_type custom_renderer[:response_content_type]
        custom_renderer[:render].call(file_path)
      else
        send_file file_path
      end
    end

    # View files (`send_file` or custom processing)
    # get 'app_route(:view)/'
    get '/' do
      case current_location_entry_type
      when :file
        view_file_response(current_location)
      when :directory then redirect app_route(:browse, loc: current_location)
      end
    end
  end
end
