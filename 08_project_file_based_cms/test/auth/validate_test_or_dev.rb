# frozen_string_literal: true

require './auth/password_digester'

module Test
  module Auth
    # Test/Dev environment Username + Password authentication.
    # For dev and test environment only. However, this serves as a template
    # for other production-grade auth services.
    class ValidateTestOrDev
      class << self
        def accept_credentials?(credentials)
          return false unless development? || test?

          credentials.fetch(:username, false) &&
            credentials.fetch(:password, false)
        end
      end

      def initialize(credentials)
        @credentials = credentials
      end

      def valid?
        user = Helpers::Users[credentials[:username]]
        return false if user.nil?
        return true if ::Auth::PasswordDigester.match?(
          user[:password], credentials[:password]
        )

        false
      end

      private

      attr_reader :credentials
    end
  end
end
