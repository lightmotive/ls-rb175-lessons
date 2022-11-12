# frozen_string_literal: true

require 'erb'

class Monroe
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
