# frozen_string_literal: true

require 'erubis'
require 'tilt/erubis'

module ViewHelpers
  # Global app helpers
  module App
    FLASH_MESSAGE_KEYS = %i[success error info].freeze

    # Append content to the `key`-specified message store.
    def self.flash_message(key, content, store:)
      MessageStore.new(store, key) << content
    end

    # Render all possible flash messages.
    def render_flash_messages(store: session, delete_after_rendering: true)
      rendered = FLASH_MESSAGE_KEYS.map do |key|
        render_flash_message(key, store:, delete_after_rendering:)
      end
      return nil if rendered.empty?

      rendered.compact.join("\n")
    end

    # Render flash message content using `MessageRenderer`.
    def render_flash_message(key, store: session, delete_after_rendering: true)
      store = MessageStore.new(store, key)
      rendered = MessageRenderer.new(store.content, css_class: key.to_s).erb
      store.clear if delete_after_rendering
      rendered
    end

    # Manage and render messages stored in a Hash-like construct, e.g., session.
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

    # Render template using Tilt::ErubisTemplate.
    class Renderer
      VIEWS_DIR_DEFAULT = 'views'
      OPTIONS_DEFAULT = { escape_html: true, trim: true }.freeze

      def initialize
        @app_root_path = File.expand_path('..', __dir__)
      end

      def views_directory
        File.join(app_root_path, VIEWS_DIR_DEFAULT)
      end

      def template(template_name, options: OPTIONS_DEFAULT)
        Tilt::ErubisTemplate.new(
          File.join(views_directory, "#{template_name}.erb"),
          options
        )
      end

      def render(template_name, options: OPTIONS_DEFAULT)
        template(template_name, options:).render(self)
      end

      private

      attr_reader :app_root_path
    end

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
