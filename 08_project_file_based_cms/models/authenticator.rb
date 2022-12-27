# frozen_string_literal: true

require 'yaml'

module Models
  # Authenticate credentials.
  class Authenticator
    class << self
      def password_for_storage(plain_text)
        # ...
      end

      def password_valid?(stored_value, provided_plain_text)
        # ...
      end
    end

    def initialize(credentials)
      @credentials = credentials
      @type = determine_type
    end

    attr_reader :credentials, :type

    # TODO: implement secure credential management system...
    def valid?
      case type
      when :username_and_password then username_and_password_valid?
      else
        # :nocov:
        false
        # :nocov:
      end
    end

    private

    def determine_type
      return :username_and_password if credentials[:username] && credentials[:password]
    end

    def username_and_password_valid?
      return true if test_or_dev_username_and_password_valid?

      # TODO: implement secure credential storage system, which can use the
      # class methods in this class for securely hashing passwords.
      # Depending on a system's security requirements, this class could support
      # multi-factor authentication, passwordless authentication, etc.
      # - Each authentication workflow would be encapsulated in its own class.
      false
    end

    # For dev and test environment only
    def test_or_dev_username_and_password_valid?
      return false unless %w[test development].include?(ENV.fetch('RACK_ENV', nil))

      user = TestUsers[credentials[:username]]
      return true if user&.[](:password) == credentials[:password]

      false
    end
  end
end
