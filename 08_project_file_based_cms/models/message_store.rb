# frozen_string_literal: true

module Models
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
end
