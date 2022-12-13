# frozen_string_literal: true

module Controllers
  # Core content behaviors.
  class ApplicationContent
    attr_reader :app_root_path

    def initialize
      # rubocop:disable Style/ExpandPathArguments
      # - Reason: `File.expand_path(__dir__)` translates symbolic links to real
      #   paths, which we don't want in this program.
      @app_root_path = File.expand_path('../../', __FILE__)
      # rubocop:enable Style/ExpandPathArguments
    end

    def content_path(child_path = '')
      content_path = String.new('content')
      content_path = File.join('test', content_path) if ENV['RACK_ENV'] == 'test'

      File.join(app_root_path, content_path, child_path)
    end

    def content_entry_type(path)
      path = content_path(path)
      return :directory if FileTest.directory?(path)
      return :file if FileTest.file?(path)

      :unknown
    end

    # Build "view" `href` attribute value based on entry type:
    # - Use `/browse` route for directories.
    # - Use `/view` route for files.
    def content_entry_set_view_href!(entry)
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
    def content_entry_set_edit_href!(entry)
      entry_path = File.join(entry[:directory], entry[:name])
      entry[:edit_href] = case entry[:type]
                          when :directory then nil
                          when :file then File.join('/', 'edit', entry_path)
                          end
      entry
    end

    def content_entries(path_start = '')
      Dir.each_child(content_path(path_start)).map do |entry_path|
        entry = {
          directory: path_start.empty? ? '/' : path_start,
          name: entry_path,
          type: content_entry_type(File.join(path_start, entry_path))
        }
        content_entry_set_view_href!(entry)
        content_entry_set_edit_href!(entry)
      end
    end
  end
end
