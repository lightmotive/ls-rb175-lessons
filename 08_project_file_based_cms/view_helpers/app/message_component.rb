# frozen_string_literal: true

require './view_helpers/component'

module ViewHelpers
  # Global app helpers
  module App
    # Render messages.
    class MessageComponent < Component
      def initialize(messages, css_class:)
        super()

        @messages = messages.compact.reject(&:empty?)
        @css_class = css_class
      end

      attr_reader :messages, :css_class

      def render(template: :flash_message_component)
        return nil if messages.empty?

        super(template)
      end
    end
  end
end
