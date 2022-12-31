# frozen_string_literal: true

require './view_helpers/app/renderer'

module ViewHelpers
  # Global app helpers
  module App
    # Render messages.
    class MessageRenderer < Renderer
      def initialize(messages, css_class:)
        super()

        @messages = messages.compact.reject(&:empty?)
        @css_class = css_class
      end

      attr_reader :messages, :css_class

      def render
        return nil if messages.empty?

        super(:flash_message)
      end
    end
  end
end
