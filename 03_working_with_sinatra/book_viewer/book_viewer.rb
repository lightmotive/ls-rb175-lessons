require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get '/' do
  @value = 'My dynamic value'
  erb :home
end
