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
    case
    when content.is_a?(Array)
      return "<p>#{content.join('</p><p>')}</p>" if content.size <= 1

      '<ul>' \
      "<li>#{content.join('</li><li>')}</li>" \
      '</ul>'
    when content.is_a?(String) then "<p>#{content}</p>"
    else
      raise 'Flash message content must be an array of strings or a string.'
    end
  end
end

def root_path
  # rubocop:disable Style/ExpandPathArguments
  # - Reason: `File.expand_path(__dir__)` translates symbolic links to real
  #   paths, which we don't want in this program.
  File.expand_path('..', __FILE__)
  # rubocop:enable Style/ExpandPathArguments
end

def content_path
  "#{root_path}/content"
end

def content_entry_type(path)
  return 'directory' if FileTest.directory?("#{content_path}#{path}")

  'file'
end

def content_entries(path_start = '/')
  entries = []

  Dir.each_child("#{content_path}#{path_start}") do |entry_path|
    next if path_start == content_path && ['.', '..'].include?(entry_path)

    entries << {
      directory: path_start,
      name: entry_path,
      type: content_entry_type("#{content_path}#{path_start}#{entry_path}")
    }
  end

  entries
end

get '/' do
  redirect '/browse'
end

get '/browse' do
  @browse_path = '/'
  @entries = content_entries

  erb :browse
end

get '/browse/*' do
  browse_path = params['splat']
  redirect '/browse' if browse_path.include?('..')
  path_local = "#{content_path}/#{browse_path}"
  redirect '/browse' unless FileTest.exists?(path_local)

  @browse_path = "/#{browse_path}"

  case content_entry_type(@browse_path)
  when 'directory'
    # Get public content entries starting at browse_path and render :browse
    @entries = content_entries(@browse_path)
    erb :browse
  when 'file'
    # Render file
    'File to be rendered...'
  else
    raise 'Unknown file type'
  end
end
