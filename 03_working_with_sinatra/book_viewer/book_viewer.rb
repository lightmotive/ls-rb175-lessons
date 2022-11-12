require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get '/' do
  @title = 'The Adventures of Sherlock Holmes'
  @toc = File.read('data/toc.txt').each_line(chomp: true)
  erb :home
end
