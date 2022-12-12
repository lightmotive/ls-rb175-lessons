# frozen_string_literal: true

module ViewHelpers
  # Global app helpers
  module ApplicationHelper
    def session_flash_messages(content)
      case
      when content.is_a?(Array)
        # :nocov:
        return "<p>#{content.join('</p><p>')}</p>" if content.size <= 1

        '<ul>' \
        "<li>#{content.join('</li><li>')}</li>" \
        '</ul>'
        # :nocov:
      when content.is_a?(String) then "<p>#{content}</p>"
      else
        # :nocov:
        raise 'Flash message content must be an array of strings or a string.'
        # :nocov:
      end
    end
  end
end
