# frozen_string_literal: true

require './test/auth/validate_test_or_dev'

module Models
  # Select and use `AuthWith...` class based on `credentials` keys.
  class Authenticator
    DEFAULT_VALIDATION_SYSTEMS = [::Test::Auth::ValidateTestOrDev].freeze

    # `validation_systems:` - Each system must be a class with the following
    # interface:
    #   - `::accept_credentials?(credentials)` - Return boolean indicating
    #     whether system can determine if `credentials` are `valid?`.
    #   - `::new(credentials)` - Accept from this class without changes.
    #   - `#valid?` - Return boolean indicating whether `credentials` are valid.
    # Conventionally, validation class names start with `Validate...`.
    def initialize(credentials, validation_systems: DEFAULT_VALIDATION_SYSTEMS)
      @credentials = credentials
      @validation_systems = validation_systems
      @validation_system = determine_system
    end

    attr_reader :credentials, :validation_system

    # TODO: implement secure credential management system...
    def valid?
      return false if validation_system.nil?

      validation_system.new(credentials).valid?
    end

    private

    attr_reader :validation_systems

    def determine_system
      validation_systems.each do |sys|
        return sys if sys.accept_credentials?(credentials)
      end

      nil
    end
  end
end
