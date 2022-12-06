# frozen_string_literal: true

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'd81b5e7a139eb9711a15d27c642ebe38e5457d86ad2d4d9c9f5df240e4d3ede8'
  set :erb, escape_html: true
end

helpers do
  def session_flash_messages(content)
    if content.is_a?(Array)
      return "<p>#{content.join('</p><p>')}</p>" if content.size <= 1

      '<ul>' \
      "<li>#{content.join('</li><li>')}</li>" \
      '</ul>'
    elsif content.is_a?(String)
      "<p>#{content}</p>"
    else
      raise 'Flash message content must be an array of strings or a string.'
    end
  end
end

def public_content_base_path
  './public/content'
end

def public_content_entry_type(path)
  return 'directory' if FileTest.directory?("#{public_content_base_path}#{path}")

  'file'
end

def public_content_entries(path_start = '/')
  entries = []

  p path_start

  Dir.each_child("#{public_content_base_path}#{path_start}") do |entry_path|
    next if path_start == public_content_base_path && ['.', '..'].include?(entry_path)

    entries << {
      directory: path_start,
      name: entry_path,
      type: public_content_entry_type("#{public_content_base_path}#{path_start}#{entry_path}")
    }
  end

  entries
end

get '/' do
  redirect '/browse'
end

get '/browse' do
  @browse_path = '/'
  @entries = public_content_entries

  erb :browse
end

get %r{/browse/(?<browse_path>.+)} do
  browse_path = params[:browse_path]
  redirect '/browse' if browse_path.include?('..')
  path_local = "#{public_content_base_path}/#{browse_path}"
  redirect '/browse' unless FileTest.exists?(path_local)

  @browse_path = "/#{browse_path}"

  case public_content_entry_type(@browse_path)
  when 'directory'
    # Get public content entries starting at browse_path and render :browse
    @entries = public_content_entries(@browse_path)
    erb :browse
  when 'file'
    # Render file
    'File to be rendered...'
  else
    raise 'Unknown file type'
  end
end
