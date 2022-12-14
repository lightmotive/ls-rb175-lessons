# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/content_for'
require 'tilt/erubis'

APP_ROUTES = { browse: '/browse',
               view: '/view',
               edit: '/edit' }.freeze

require './url_utils'
Dir.glob('./models/*.rb').sort.each { |file| require file }
Dir.glob('./controllers/*.rb').sort.each { |file| require file }

# Rack-compliant app
class App
  attr_reader :app

  def initialize
    @app = Rack::Builder.app do
      map(APP_ROUTES[:edit]) { run Controllers::EditController.new }
      map(APP_ROUTES[:view]) { run Controllers::ViewController.new }
      map(APP_ROUTES[:browse]) { run Controllers::BrowseController.new }
      map('/') { run Controllers::ApplicationController.new }
    end
  end

  def call(env)
    app.call(env)
  end
end
