# frozen_string_literal: true

module ViewHelpers
  # Global app helpers
  module ApplicationHelper
    # Output flash message content
    def render_flash_messages(flash_key, store: session, delete_after_rendering: true)
      store = MessageStore.new(store, flash_key)
      rendered = MessageRenderer.new(store.content).html
      store.clear if delete_after_rendering
      rendered
    end

    # Append content to the `flash_key`-specified message store.
    def self.flash_message(flash_key, content, store:)
      MessageStore.new(store, flash_key) << content
    end

    # Manage and render messages stored in a Hash-like construct.
    class MessageStore
      def initialize(store, message_key)
        @store = store
        @message_key = message_key
      end

      # Append a string or array of strings to current messages.
      def append(content_to_append)
        content_stored = content

        if content_to_append.is_a?(Array)
          content_stored.concat(content_to_append)
        else
          content_stored << content_to_append
        end

        self.content = content_stored
      end

      alias << append

      def content
        store.fetch(message_key, []) || []
      end

      def content=(value)
        store[message_key] = value
      end

      def clear
        store.delete(message_key)
      end

      private

      attr_reader :store, :message_key
    end

    # Render messages
    class MessageRenderer
      def initialize(messages)
        @messages = messages
      end

      attr_reader :messages

      def erb(template_key)
        erb template_key
      end

      def html
        messages = self.messages.compact.reject(&:empty?)
        return '' if messages.empty?
        return "<p>#{Rack::Utils.escape_html(messages.first)}</p>" if messages.size == 1

        <<~CONTENT
          <ul>
          <li>#{messages.map { |c| Rack::Utils.escape_html(c) }.join("</li>\n<li>")}</li>
          </ul>
        CONTENT
      end
    end
  end
end
