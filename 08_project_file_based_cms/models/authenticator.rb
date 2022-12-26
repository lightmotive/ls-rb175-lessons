# frozen_string_literal: true

require 'yaml'

module Models
  # Authenticate credentials.
  class Authenticator
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

      # TODO: implement secure credential management system...
      false
    end

    def test_or_dev_username_and_password_valid?
      return false unless %w[test development].include?(ENV.fetch('RACK_ENV', nil))

      user = test_user(credentials[:username])
      return true if user&.[]('password') == credentials[:password]
    end
  end
end
