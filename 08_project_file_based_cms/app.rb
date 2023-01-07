# frozen_string_literal: true

# TODO: remaining tasks
# - Rename routes and associated classes that inherit BrowseController:
#   - Prefix route name with `:browse` and value with `/browse`.
#   - Prefix class names with `Browse`.
#   - Ensure routes are mapped before base `/browse` route.

require 'sinatra/base'
require 'sinatra/content_for'
require 'tilt/erubi'

require './cms_app_helper'
require './url_utils'
Dir.glob('./models/*.rb').each { |file| require file }
Dir.glob('./view_helpers/**/*.rb').each { |file| require file }
Dir.glob('./controllers/*.rb').each { |file| require file }

# TODO: set the following env vars using environment management systems:
# - For dev and test: https://github.com/bkeepers/dotenv
# - For production, use host framework's secure environment management system.
if development?
  # :nocov:
  require './test/auth/helpers'

  Test::Auth::Helpers::TempUsers.create
  # :nocov:
end

# Rack-compliant app
class App
  include CMSAppHelper
  attr_reader :app

  def initialize
    @app = rack_app
  end

  def call(env)
    app.call(env)
  end

  private

  # Map routes using `Rack::Builder#app`.
  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
  def rack_app
    Rack::Builder.app do
      map(APP_ROUTES[:logout]) { run Controllers::LogoutController.new }
      map(APP_ROUTES[:index]) { run Controllers::ApplicationController.new }
      map(APP_ROUTES[:login]) { run Controllers::LoginController.new }
      map(APP_ROUTES[:view]) { run Controllers::ViewController.new }
      map(APP_ROUTES[:edit]) { run Controllers::EditController.new }
      map(APP_ROUTES[:delete]) { run Controllers::DeleteController.new }
      map(APP_ROUTES[:browse]) { run Controllers::BrowseController.new }
      map(APP_ROUTES[:rename_entry]) { run Controllers::RenameEntryController.new }
      map(APP_ROUTES[:new_entry]) { run Controllers::NewEntryController.new }
      map(APP_ROUTES[:upload]) { run Controllers::UploadController.new }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
end

if development?
  # :nocov:
  at_exit do
    Test::Auth::Helpers::TempUsers.destroy
  end
  # :nocov:
end
