# frozen_string_literal: true

require './models/message_store'
require './view_helpers/app/message_component'

module ViewHelpers
  # Global app helpers
  module App
    FLASH_MESSAGE_KEYS = %i[success error info].freeze

    # Append content to the `key`-specified message store.
    def self.flash_message(key, content, store:)
      ::Models::MessageStore.new(store, key) << content
    end

    # Render all possible flash messages.
    def render_flash_messages(store: session, delete_after_rendering: true)
      rendered = FLASH_MESSAGE_KEYS.map do |key|
        render_flash_message(key, store:, delete_after_rendering:)
      end
      return nil if rendered.empty?

      rendered.compact.join("\n")
    end

    # Render flash message content using `MessageComponent`.
    def render_flash_message(key, store: session, delete_after_rendering: true)
      store = ::Models::MessageStore.new(store, key)
      rendered = MessageComponent.new(store.content, css_class: key.to_s).render
      store.clear if delete_after_rendering
      rendered
    end
  end
end
