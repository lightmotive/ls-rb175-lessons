# frozen_string_literal: true

require 'erb'
require_relative 'advice' # loads advice.rb

class HelloWorld
  def call(env)
    case env['REQUEST_PATH']
    when '/'
      ['200', { 'Content-Type' => 'text/html' },
       [erb_by_physical_path('views/index.erb').result]]
    when '/advice'
      piece_of_advice = Advice.new.generate
      [
        '200',
        { 'Content-Type' => 'text/html' },
        ["<html><body><b><em>#{piece_of_advice}</em></b></body></html>"]
      ]
    else
      [
        '404',
        { 'Content-Type' => 'text/html', 'Content-Length' => '48' },
        ['<html><body><h4>404 Not Found</h4></body></html>']
      ]
    end
  end

  def erb_by_physical_path(path)
    template = File.read(path)
    ERB.new(template)
  end
end
