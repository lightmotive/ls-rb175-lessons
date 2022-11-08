# frozen_string_literal: true

class HelloWorld
  def call(_env)
    ['200', { 'Content-Type' => 'text/plain' }, ['Hello World!']]
  end
end
