# frozen_string_literal: true

require 'erb'
require_relative 'advice' # loads advice.rb

class HelloWorld
  def call(env)
    case env['REQUEST_PATH']
    when '/'
      ['200', { 'Content-Type' => 'text/html' }, [erb(:index)]]
    when '/advice'
      [
        '200', { 'Content-Type' => 'text/html' },
        [erb(:advice, message: Advice.new.generate)]
      ]
    else
      ['404', { 'Content-Type' => 'text/html' }, [erb(:not_found)]]
    end
  end

  private

  def erb(route, local = {})
    b = binding
    template = File.read("views/#{route}.erb")
    ERB.new(template).result(b)
  end
end
