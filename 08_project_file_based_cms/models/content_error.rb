# frozen_string_literal: true

module Models
  class ContentError < StandardError
    def initialize(message = '')
      super()

      @messages = []
      self.<<(message) unless message&.empty?
    end

    attr_reader :messages

    def any?
      @messages.any?
    end

    def <<(message)
      @messages << message
    end

    def message
      @messages.join(' ')
    end
  end
end
