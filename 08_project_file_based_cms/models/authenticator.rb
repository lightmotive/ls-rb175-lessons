# frozen_string_literal: true

require './auth/test_or_dev'

module Models
  # Select and use `AuthWith...` class based on `credentials` keys.
  class Authenticator
    DEFAULT_SUPPORTED_SYSTEMS = [Auth::TestOrDev].freeze

    # `supported_systems:` - Each system must be a class with the following
    # interface:
    #   - `::accept_credentials?(credentials)` - Return boolean indicating
    #     whether system can determine if `credentials` are `valid?`.
    #   - `::new(credentials)` - Accept from this class without changes.
    #   - `#valid?` - Return boolean indicating whether `credentials` are valid.
    def initialize(credentials, supported_systems: DEFAULT_SUPPORTED_SYSTEMS)
      @credentials = credentials
      @supported_systems = supported_systems
      @system = determine_system
    end

    attr_reader :credentials, :system

    # TODO: implement secure credential management system...
    def valid?
      return false if system.nil?

      system.new(credentials).valid?
    end

    private

    attr_reader :supported_systems

    def determine_system
      supported_systems.each do |system|
        return system if system.accept_credentials?(credentials)
      end

      nil
    end
  end
end
