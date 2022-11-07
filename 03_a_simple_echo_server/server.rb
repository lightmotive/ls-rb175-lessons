# frozen_string_literal: true

require 'socket'

server = TCPServer.new('ls-ruby-container', 49_152)

def parse_params(uri_or_query_string)
  return {} if uri_or_query_string.nil? || uri_or_query_string.empty? ||
               !uri_or_query_string.include?('=')

  uri_or_query_string = uri_or_query_string.split('?')[1] if uri_or_query_string.include?('?')

  pairs = uri_or_query_string.split('&')
  pairs.each_with_object({}) do |pair, hash|
    key, value = pair.split('=')
    hash[key] = value
  end
end

def respond_with_status_and_close(client, status: '200 OK')
  client.puts("HTTP/1.1 #{status}")
  client.close
end

# => { :method, :path, :params, :version }
def parse_request_start_line(start_line)
  method, request_uri, version = start_line.split(' ')
  path, query_string = request_uri.split('?')

  { method: method, path: path,
    params: parse_params(query_string),
    version: version }
end

def respond_to_path_roll(request_components, client)
  request_params = request_components[:params]

  rolls = request_params['count']&.to_i || 1
  sides = request_params['sides']&.to_i || 6

  client.puts 'HTTP/1.1 200 OK'
  client.puts "Content-Type: text/plain\r\n\r\n"
  rolls.times do
    client.puts rand(1..sides)
  end
end

def respond_to_path_unknown(request_components, client)
  client.puts('HTTP/1.1 404 Not Found')
  client.puts "Content-Type: text/plain\r\n\r\n"
  client.puts "'#{request_components[:path]}' path not found."
end

def respond_to_path(request_components, client)
  case request_components[:path]
  when '/roll' then respond_to_path_roll(request_components, client)
  else
    respond_to_path_unknown(request_components, client)
  end
end

loop do
  client = server.accept

  request_start_line = client.gets
  next respond_with_status_and_close(client) if !request_start_line || request_start_line =~ /favicon/

  puts request_start_line
  request_components = parse_request_start_line(request_start_line)
  respond_to_path(request_components, client)

  client.close
end
