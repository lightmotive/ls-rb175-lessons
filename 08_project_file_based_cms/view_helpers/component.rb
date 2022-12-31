# frozen_string_literal: true

require 'erubis'
require 'tilt/erubis'

module ViewHelpers
  # Render template using Tilt::ErubisTemplate.
  class Component
    VIEWS_DIR_DEFAULT = 'views'
    OPTIONS_DEFAULT = { escape_html: true, trim: true }.freeze

    def initialize
      @app_root_path = File.expand_path('../', __dir__)
    end

    def views_directory
      File.join(app_root_path, VIEWS_DIR_DEFAULT)
    end

    def template(template_name, options: OPTIONS_DEFAULT)
      Tilt::ErubisTemplate.new(
        File.join(views_directory, "#{template_name}.erb"),
        options
      )
    end

    def render(template_name, options: OPTIONS_DEFAULT)
      template(template_name, options:).render(self)
    end

    private

    attr_reader :app_root_path
  end
end
