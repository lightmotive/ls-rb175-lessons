# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'content_test_mod'
require './view_helpers/content_entry_component'
require './app/core'

# Application view helpers
class HelperContentEntryComponentTest < MiniTest::Test
  include ContentTestMod
  include AppRoutes

  def test_text_file_render
    create_file('test.txt')
    entry = content_entries.first
    component = ViewHelpers::ContentEntryComponent.new(entry)
    assert_equal expected_content(entry, component), component.render
  end

  def test_directory_render
    create_directory('dir1')
    entry = content_entries.first
    component = ViewHelpers::ContentEntryComponent.new(entry)
    assert_equal expected_content(entry, component, edit: false), component.render
  end

  def test_image_file_render
    create_directory(directory = 'dir1')
    create_file('test.jpg', in_loc: directory)
    entry = content_entries(directory).first
    component = ViewHelpers::ContentEntryComponent.new(entry)
    assert_equal expected_content(entry, component, edit: false), component.render
  end

  def test_unknown_entry_render
    entry = Models::ContentEntry.new(
      dir_relative: '/', basename: 'nada.xyz', path_absolute: 'nada-abc123'
    )
    component = ViewHelpers::ContentEntryComponent.new(entry)
    assert_empty component.render
  end

  private

  EXPECTED_CONTENT_OPTIONS_DEFAULT = {
    view: true, rename: true, edit: true, delete: true
  }.freeze

  # rubocop:disable Metrics/MethodLength
  def expected_content(entry, component,
                       options = EXPECTED_CONTENT_OPTIONS_DEFAULT)
    options = EXPECTED_CONTENT_OPTIONS_DEFAULT.merge(options)
    content = String.new

    content = %(<a href="#{component.view_href}">#{entry.name}</a>) if options[:view]
    content << %(\n<a class="rename link-icon" href="#{component.rename_href}"></a>) if options[:rename]
    content << %(\n<a class="edit link-icon" href="#{component.edit_href}"></a>) if options[:edit]

    if options[:delete]
      content << <<~CONTENT
        \n<form class="inline delete" action="#{component.delete_action}" method="post">
          <button class="delete" type="submit"></button>
        </form>
      CONTENT
    end

    content
  end
  # rubocop:enable Metrics/MethodLength
end
