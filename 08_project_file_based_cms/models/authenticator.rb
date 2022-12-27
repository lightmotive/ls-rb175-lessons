# frozen_string_literal: true

require './auth/test_or_dev'

SUPPORTED_AUTH_SYSTEMS = [Auth::TestOrDev].freeze
# System must be a class with the following interface:
# - `::accept_credentials?(credentials)` - Return boolean indicating whether
#   system can determine if `credentials` are `valid?`.
# - `::new(credentials)` - Accept from this class without changes.
# - `#valid?` - Return boolean indicating whether `credentials` are valid.

module Models
  # Select and use `AuthWith...` class based on `credentials` keys.
  class Authenticator
    def initialize(credentials)
      @credentials = credentials
      @type = determine_type
    end

    attr_reader :credentials, :type

    # TODO: implement secure credential management system...
    def valid?
      return false if type.nil?

      type.new(credentials).valid?
    end

    private

    def determine_type
      SUPPORTED_AUTH_SYSTEMS.each do |system|
        return system if system.accept_credentials?(credentials)
      end

      nil
    end
  end
end
