# frozen_string_literal: true

require_relative 'application_controller'
require 'redcarpet'

module Controllers
  # Handle '/view' routes.
  class ViewController < ApplicationController
    # TODO: Refactor to class with separate classes mapped for each file type.
    def custom_file_renderers
      {
        '.md' => { response_content_type: :html,
                   render: lambda do |local_file_path|
                     markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
                     markdown.render(File.read(local_file_path))
                   end }
      }
    end

    def view_file_response(view_path)
      local_file_path = content_path(view_path)
      file_extension = File.extname(local_file_path)

      custom_renderer = custom_file_renderers[file_extension]
      if custom_renderer
        content_type custom_renderer[:response_content_type]
        custom_renderer[:render].call(local_file_path)
      else
        send_file local_file_path
      end
    end

    # View files (`send_file` or custom processing)
    # get '/view/*'
    get '/*' do
      view_path = params['splat'].first
      validate_request_entry_path(view_path)

      case content_entry_type(view_path)
      when :file
        view_file_response(view_path)
      when :directory then redirect File.join('/', 'browse', view_path)
      else
        content_missing(view_path)
      end
    end
  end
end
