# frozen_string_literal: true

require './monroe'
require './advice'

class App < Monroe
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
end
