require './app/core'
require './view_helpers/app'

# Base mock for view-related unit tests.
class ViewMock
  include ViewHelpers::App
  include AppRoutes

  def initialize
    @session = {}
  end

  attr_reader :session
end
