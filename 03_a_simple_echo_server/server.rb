# frozen_string_literal: true

require 'socket'

server = TCPServer.new('ls-ruby-container', 49_152)

loop do
  client = server.accept

  request_line1 = client.gets
  puts request_line1

  client.puts 'HTTP/1.1 200 OK'
  client.puts "Content-Type: text/plain\r\n\r\n"
  client.puts request_line1
  client.close
end
