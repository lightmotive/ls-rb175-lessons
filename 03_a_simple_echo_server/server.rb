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

def respond_to_path_roll(request, client)
  params = request[:params]

  rolls = params['count']&.to_i || 1
  sides = params['sides']&.to_i || 6

  client.puts 'HTTP/1.1 200 OK'
  client.puts "Content-Type: text/html\r\n\r\n"
  client.puts '<html>'
  client.puts '<body>'
  client.puts '<h1>Rolls</h1>'
  client.puts '<div>'
  roll_results = rolls.times.map do
    rand(1..sides)
  end
  client.puts roll_results.join(', ')
  client.puts '</div>'
  client.puts '</body>'
  client.puts '</html>'
end

def respond_to_path_unknown(request, client)
  client.puts('HTTP/1.1 404 Not Found')
  client.puts "Content-Type: text/plain\r\n\r\n"
  client.puts "'#{request[:path]}' path not found."
end

def respond_to_path(request, client)
  case request[:path]
  when '/roll' then respond_to_path_roll(request, client)
  else
    respond_to_path_unknown(request, client)
  end
end

loop do
  client = server.accept

  request_start_line = client.gets
  next respond_with_status_and_close(client) if !request_start_line || request_start_line =~ /favicon/

  puts request_start_line
  request = parse_request_start_line(request_start_line)
  respond_to_path(request, client)

  client.close
end
