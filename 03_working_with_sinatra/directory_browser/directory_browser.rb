require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get '/' do
  @filenames = []
  Dir.foreach('public').map do |name|
    next if ['.', '..'].include?(name) || File.directory?(name)

    @filenames << name
  end

  erb :home
end
