# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/content_for'
require 'tilt/erubis'

APP_ROUTES = { browse: '/browse',
               view: '/view',
               edit: '/edit',
               delete: '/delete',
               new_dir: '/new/dir',
               new_file: '/new/file',
               index: '/' }.freeze

require './url_utils'
Dir.glob('./models/*.rb').sort.each { |file| require file }
Dir.glob('./view_helpers/*.rb').sort.each { |file| require file }
Dir.glob('./controllers/*.rb').sort.each { |file| require file }

# Rack-compliant app
class App
  attr_reader :app

  def initialize
    @app = Rack::Builder.app do
      map(APP_ROUTES[:view]) { run Controllers::ViewController.new }
      map(APP_ROUTES[:edit]) { run Controllers::EditController.new }
      map(APP_ROUTES[:delete]) { run Controllers::DeleteController.new }
      map(APP_ROUTES[:browse]) { run Controllers::BrowseController.new }
      map(APP_ROUTES[:new_dir]) { run Controllers::NewDirController.new }
      map(APP_ROUTES[:new_file]) { run Controllers::NewFileController.new }
      map(APP_ROUTES[:index]) { run Controllers::ApplicationController.new }
    end
  end

  def call(env)
    app.call(env)
  end
end
