# frozen_string_literal: true

require_relative 'advice' # loads advice.rb

class HelloWorld
  def call(env)
    case env['REQUEST_PATH']
    when '/'
      ['200', { 'Content-Type' => 'text/plain' }, ['Hello World!']]
    when '/advice'
      piece_of_advice = Advice.new.generate    # random piece of advice
      ['200', { 'Content-Type' => 'text/plain' }, [piece_of_advice]]
    else
      [
        '404',
        { 'Content-Type' => 'text/plain', 'Content-Length' => '13' },
        ['404 Not Found']
      ]
    end
  end
end
