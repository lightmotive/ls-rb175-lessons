require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

TOC = File.read('data/toc.txt').each_line(chomp: true)

get '/' do
  @title = 'The Adventures of Sherlock Holmes'
  @content_subhead = 'Table of Contents'
  erb :home
end
