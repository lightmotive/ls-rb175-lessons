# frozen_string_literal: true

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
      if %w[test development].include?(
        ENV.fetch('RACK_ENV', nil)
      ) && (credentials[:username] == ENV['TEST_OR_DEV_USER_USERNAME'] &&
            credentials[:password] == ENV['TEST_OR_DEV_USER_PASSWORD'])
        return true
      end

      # TODO: implement secure credential management system...
      false
    end
  end
end
