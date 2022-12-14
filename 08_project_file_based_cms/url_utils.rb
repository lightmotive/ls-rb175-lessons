# frozen_string_literal: true

# TODO: Refactor and publish this as a Gem.
# URL Utilities
module URLUtils
  PATH_SEPARATOR = '/'

  # Join relative URL path components without worrying about leading and
  # trailing slashes.
  def self.join_components(*components)
    PathNormalizer.new(components).joined
  end

  class PathNormalizer
    attr_reader :components_normalized

    def initialize(components)
      @components_normalized = compact(normalize(components.flatten))
    end

    def joined
      squeeze_separators(components_normalized.join(PATH_SEPARATOR))
    end

    private

    # - Retain single leading separators for first component, if any.
    # - Remove leading and trailing separators from middle components.
    # - Retain single trailing slash for last component, if any.
    def normalize(components)
      components = compact(components)
      return [''] if components.empty?

      components[0] = normalize_first_component(components[0])
      return components if components.size == 1

      components[-1] = normalize_last_component(components[-1])
      return components if components.size == 2

      components[1..-2] = normalize_middle_components(components[1..-2])

      components
    end

    # - Remove nil and empty elements.
    # - Consolidate sequential separators in each component into one.
    def compact(components)
      components.compact.reject(&:empty?).map(&method(:squeeze_separators))
    end

    # Squeeze sequential separators, e.g., '//example///' => '/example/'
    def squeeze_separators(component)
      component.squeeze(PATH_SEPARATOR)
    end

    def trim_leading_separators(component)
      component.match(/(?:\A#{PATH_SEPARATOR}*)(.*)/)[1]
    end

    def trim_trailing_separators(component)
      match = component.match(/.*(?=#{PATH_SEPARATOR}+\z)/)
      return component if match.nil?

      match[0]
    end

    # Retain up to 1 leading separator and remove trailing separators
    def normalize_first_component(component)
      match = component.match(/\A(#{PATH_SEPARATOR})?\1*(.*)/)
      return '' if match.nil?

      component = "#{match[1]}#{match[2]}"
      return component if component == PATH_SEPARATOR

      trim_trailing_separators(component)
    end

    # Remove leading and trailing separators
    def normalize_middle_components(components)
      components.map do |component|
        component = trim_leading_separators(component)
        trim_trailing_separators(component)
      end
    end

    def normalize_last_component(component)
      trim_leading_separators(component)
    end
  end
end
