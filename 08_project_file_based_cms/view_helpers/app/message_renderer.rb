# frozen_string_literal: true

require_relative 'renderer'

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

      def erb
        return nil if messages.empty?

        render(:flash_message)
      end
    end
  end
end
