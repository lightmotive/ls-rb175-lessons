# frozen_string_literal: true

# TODO: Refactor and publish this as a Gem.
# URL Utilities
module URLUtils
  PATH_SEPARATOR = '/'

  # Join relative URL path paths without worrying about leading and
  # trailing slashes.
  def self.join_paths(*paths)
    PathNormalizer.new(paths).joined
  end

  class PathNormalizer
    attr_reader :paths_normalized

    def initialize(paths)
      @paths_normalized = compact(normalize(paths.flatten))
    end

    def joined
      squeeze_separators(paths_normalized.join(PATH_SEPARATOR))
    end

    private

    # - Retain single leading separators for first path, if any.
    # - Remove leading and trailing separators from middle paths.
    # - Retain single trailing slash for last path, if any.
    def normalize(paths)
      paths = compact(paths)
      return [''] if paths.empty?

      paths[0] = normalize_first_path(paths[0])
      return paths if paths.size == 1

      paths[-1] = normalize_last_path(paths[-1])
      return paths if paths.size == 2

      paths[1..-2] = normalize_middle_paths(paths[1..-2])

      paths
    end

    # - Remove nil and empty elements.
    # - Consolidate sequential separators in each path into one.
    def compact(paths)
      paths.compact.reject(&:empty?).map(&method(:squeeze_separators))
    end

    # Squeeze sequential separators, e.g., '//example///' => '/example/'
    def squeeze_separators(path)
      path.squeeze(PATH_SEPARATOR)
    end

    def trim_leading_separators(path)
      path = path[1..] while path.start_with?(PATH_SEPARATOR)
      path
    end

    def trim_trailing_separators(path)
      return path if path.length < 2

      path = path[0..-2] while path.end_with?(PATH_SEPARATOR)
      path
    end

    # Retain up to 1 leading separator and remove trailing separators
    def normalize_first_path(path)
      return path if path == PATH_SEPARATOR

      trim_trailing_separators(path)
    end

    # Remove leading and trailing separators
    def normalize_middle_paths(paths)
      paths.map do |path|
        path = trim_leading_separators(path)
        trim_trailing_separators(path)
      end
    end

    def normalize_last_path(path)
      trim_leading_separators(path)
    end
  end
end
