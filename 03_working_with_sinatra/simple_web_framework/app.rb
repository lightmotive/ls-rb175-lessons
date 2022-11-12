# frozen_string_literal: true

require 'erb'
require_relative 'advice' # loads advice.rb

class App
  def call(env)
    case env['REQUEST_PATH']
    when '/'
      response('200', { 'Content-Type' => 'text/html' }) do
        erb(:index)
      end
    when '/advice'
      response('200', { 'Content-Type' => 'text/html' }) do
        erb(:advice, message: Advice.new.generate)
      end
    else
      response('404', { 'Content-Type' => 'text/html' }) do
        erb(:not_found)
      end
    end
  end

  private

  def erb(route, local = {})
    b = binding
    template = File.read("views/#{route}.erb")
    ERB.new(template).result(b)
  end

  def response(status, headers, body = '')
    body = yield if block_given?
    [status, headers, [body]]
  end
end
