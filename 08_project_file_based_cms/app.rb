# frozen_string_literal: true

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'

get '/' do
  'Getting started.'
end
