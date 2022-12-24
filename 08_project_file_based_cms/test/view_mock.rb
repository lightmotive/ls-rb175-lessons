require './cms_app_helper'
require './view_helpers/app'

# Base mock for view-related unit tests.
class ViewMock
  include ViewHelpers::App
  include CMSAppHelper

  def initialize
    @session = {}
  end

  attr_reader :session
end
