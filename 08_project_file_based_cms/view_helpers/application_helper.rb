# frozen_string_literal: true

module ViewHelpers
  # Global app helpers
  module ApplicationHelper
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
