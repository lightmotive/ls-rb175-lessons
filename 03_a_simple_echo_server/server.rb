# frozen_string_literal: true

require 'socket'

server = TCPServer.new('ls-ruby-container', 49_152)

def params_from_query_string(query_string)
  return {} if query_string.nil? || query_string.empty?

  query_string = query_string.slice(1..) if query_string.start_with?('?')

  param_pairs = query_string.split('&')

  param_pairs.each_with_object({}) do |pair, hash|
    key, value = pair.split('=')
    hash[key] = value
  end
end

def empty_response(client, status: '200 OK')
  client.puts("HTTP/1.1 #{status}")
  client.close
end

# => [method, path, query_string, http_version]
def request_start_line_components(start_line)
  method, request_uri, http_version = start_line.split(' ')
  path, query_string = request_uri.split('?')

  { method: method, path: path,
    params: params_from_query_string(query_string),
    http_version: http_version }
end

def process_path_roll(request_components, client)
  request_params = request_components[:params]

  rolls = request_params['count']&.to_i || 1
  sides = request_params['sides']&.to_i || 6

  client.puts 'HTTP/1.1 200 OK'
  client.puts "Content-Type: text/plain\r\n\r\n"
  rolls.times do
    client.puts rand(1..sides)
  end
end

def process_path_unknown(request_components, client)
  client.puts('HTTP/1.1 404 Not Found')
  client.puts "Content-Type: text/plain\r\n\r\n"
  client.puts "'#{request_components[:path]}' path not found."
end

def process_path(request_components, client)
  case request_components[:path]
  when '/roll' then process_path_roll(request_components, client)
  else
    process_path_unknown(request_components, client)
  end
end

loop do
  client = server.accept

  request_start_line = client.gets
  next empty_response(client) if !request_start_line || request_start_line =~ /favicon/

  puts request_start_line
  request_components = request_start_line_components(request_start_line)
  process_path(request_components, client)

  client.close
end
