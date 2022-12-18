# frozen_string_literal: true

require 'uri'
require './url_utils'

module ViewHelpers
  # Global app helpers
  module ApplicationHelper
    def app_route(route, path: '', loc: nil, query: {})
      route = APP_ROUTES[route]

      loc = nil if loc == '/'
      unless loc.nil? || loc.empty?
        loc = "/#{loc}" unless loc.start_with?('/')
        query = { loc: loc }.merge(query) unless loc.empty?
      end
      query_string = query.empty? ? '' : "?#{URI.encode_www_form(query)}"

      "#{URLUtils.join_components(route, path)}#{query_string}"
    end

    def session_flash_messages(content)
      return '' if content.nil?

      case
      when content.is_a?(Array)
        return "<p>#{Rack::Utils.escape_html(content.first)}</p>" if content.size == 1

        <<~CONTENT
          <ul>
          <li>#{content.map { |c| Rack::Utils.escape_html(c) }.join("</li>\n<li>")}</li>
          </ul>
        CONTENT
      when content.is_a?(String) then content.empty? ? '' : "<p>#{Rack::Utils.escape_html(content)}</p>"
      else
        raise 'Flash message content must be an array or a string.'
      end
    end
  end
end
