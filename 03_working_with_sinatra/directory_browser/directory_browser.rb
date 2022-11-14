require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get '/' do
  @filenames = []
  Dir.foreach('public') do |name|
    next if ['.', '..'].include?(name) || File.directory?(name)

    @filenames << name
  end
  @filenames.sort

  @sort_order = params['sort'] || 'asc'
  @filenames.reverse! if @sort_order == 'desc'

  erb :home
end
