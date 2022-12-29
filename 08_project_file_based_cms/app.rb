# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/content_for'
require 'tilt/erubis'

require './cms_app_helper'
require './url_utils'
Dir.glob('./models/*.rb').each { |file| require file }
Dir.glob('./view_helpers/*.rb').each { |file| require file }
Dir.glob('./controllers/*.rb').each { |file| require file }

# TODO: set the following env vars using environment management systems:
# - For dev and test: https://github.com/bkeepers/dotenv
# - For production, use host framework's secure environment management system.
if development?
  # :nocov:
  require './auth/test_helpers'

  Auth::TestHelpers::TempUsers.create
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
      map(APP_ROUTES[:new_dir]) { run Controllers::NewDirController.new }
      map(APP_ROUTES[:new_file]) { run Controllers::NewFileController.new }
      map(APP_ROUTES[:upload]) { run Controllers::UploadController.new }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
end

if development?
  # :nocov:
  at_exit do
    Auth::TestHelpers::TempUsers.destroy
  end
  # :nocov:
end
