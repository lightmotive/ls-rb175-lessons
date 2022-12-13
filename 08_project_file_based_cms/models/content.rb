# frozen_string_literal: true

module Models
  # Core content behaviors.
  class Content
    attr_reader :app_root_path

    def initialize
      # rubocop:disable Style/ExpandPathArguments
      # - Reason: `File.expand_path(__dir__)` translates symbolic links to real
      #   paths, which we don't want in this program.
      @app_root_path = File.expand_path('../../', __FILE__)
      # rubocop:enable Style/ExpandPathArguments
    end

    def path(child_path = '')
      path = String.new('content')
      path = File.join('test', path) if ENV['RACK_ENV'] == 'test'

      File.join(app_root_path, path, child_path)
    end

    def entry_type(path)
      path = path(path)
      return :directory if FileTest.directory?(path)
      return :file if FileTest.file?(path)

      :unknown
    end

    def entries(path_start = '')
      Dir.each_child(path(path_start)).map do |entry_path|
        entry = {
          directory: path_start.empty? ? '/' : path_start,
          name: entry_path,
          type: entry_type(File.join(path_start, entry_path))
        }
        apply_view_href(entry)
        apply_edit_href(entry)
      end
    end

    private

    # Build "view" `href` attribute value based on entry type:
    # - Use `/browse` route for directories.
    # - Use `/view` route for files.
    def apply_view_href(entry)
      entry_path = File.join(entry[:directory], entry[:name])
      entry[:view_href] = case entry[:type]
                          when :directory then File.join('/', 'browse', entry_path)
                          when :file then File.join('/', 'view', entry_path)
                          end
      entry
    end

    # Build "edit" `href` attribute value based on entry type:
    # - Use `/edit` route for files.
    # - Disable for directories (assign `nil`).
    def apply_edit_href(entry)
      entry_path = File.join(entry[:directory], entry[:name])
      entry[:edit_href] = case entry[:type]
                          when :directory then nil
                          when :file then File.join('/', 'edit', entry_path)
                          end
      entry
    end
  end
end
