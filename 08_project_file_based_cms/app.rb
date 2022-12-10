# frozen_string_literal: true

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'redcarpet'

configure do
  enable :sessions
  set :session_secret, 'd81b5e7a139eb9711a15d27c642ebe38e5457d86ad2d4d9c9f5df240e4d3ede8'
  set :erb, escape_html: true
end

helpers do
  def session_flash_messages(content)
    case
    when content.is_a?(Array)
      # :nocov:
      return "<p>#{content.join('</p><p>')}</p>" if content.size <= 1

      '<ul>' \
      "<li>#{content.join('</li><li>')}</li>" \
      '</ul>'
      # :nocov:
    when content.is_a?(String) then "<p>#{content}</p>"
    else
      # :nocov:
      raise 'Flash message content must be an array of strings or a string.'
      # :nocov:
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

def content_path(child_path = '')
  File.join(root_path, 'content', child_path)
end

def content_entry_type(path)
  path = content_path(path)
  return :directory if FileTest.directory?(path)
  return :file if FileTest.file?(path)

  :unknown
end

def content_entries(path_start = '')
  Dir.each_child(content_path(path_start)).map do |entry_path|
    {
      directory: path_start.empty? ? '/' : path_start,
      name: entry_path,
      type: content_entry_type(File.join(path_start, entry_path))
    }
  end
end

def content_missing(missing_path)
  session[:error] = "#{File.join('/', missing_path)} wasn't found."
  redirect '/browse'
end

get '/' do
  redirect '/browse'
end

namespace '/browse' do
  helpers do
    # Build complete `/view/` route `href` attribute value
    def browse_entry_href(entry)
      entry_path = File.join(entry[:directory], entry[:name])

      case entry[:type]
      when :directory
        File.join('/', 'browse', entry_path)
      when :file
        File.join('/', 'view', entry_path)
      else
        # :nocov:
        ''
        # :nocov:
      end
    end
  end

  # get '/browse'
  get do
    @browse_path = '/'
    @entries = content_entries

    erb :browse
  end

  # get '/browse/*'
  # Get public content entries starting at browse_path and render :browse if
  # :directory or redirect to view file if :file
  get '/*' do
    @browse_path = params['splat'].first
    # The web or app server handles this scenario automatically; just in case:
    halt 404 if @browse_path.include?('..')

    case content_entry_type(@browse_path)
    when :directory
      @entries = content_entries(@browse_path)
      erb :browse
    when :file
      redirect File.join('/', 'view', @browse_path)
    else
      content_missing(@browse_path)
    end
  end
end

def view_file_response(view_path)
  local_file_path = content_path(view_path)

  case File.extname(local_file_path)
  when '.md'
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(File.read(local_file_path))
  else
    send_file local_file_path
  end
end

# View files (`send_file` or custom processing)
get '/view/*' do
  view_path = params['splat'].first
  # The web or app server handles this scenario automatically; just in case:
  halt 404 if view_path.include?('..')

  case content_entry_type(view_path)
  when :file
    view_file_response(view_path)
  when :directory then redirect File.join('/', 'browse', view_path)
  else
    content_missing(view_path)
  end
end
