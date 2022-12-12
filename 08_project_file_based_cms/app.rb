# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/content_for'
require 'tilt/erubis'

require_app_paths = Dir.glob('./controllers/*.rb')
require_app_paths.sort.each { |file| require file }

# Rack app.
class App
  attr_reader :app

  def initialize
    @app = Rack::Builder.app do
      map('/edit') { run Controllers::EditController.new }
      map('/view') { run Controllers::ViewController.new }
      map('/browse') { run Controllers::BrowseController.new }
      map('/') { run Controllers::ApplicationController.new }
    end
  end

  def call(env)
    app.call(env)
  end
end
