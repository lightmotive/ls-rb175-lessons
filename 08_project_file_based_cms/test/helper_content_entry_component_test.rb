# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'content_test_mod'
require './view_helpers/content_entry_component'
require './cms_app_helper'

# Application view helpers
class HelperContentEntryComponentTest < MiniTest::Test
  include ContentTestMod
  include CMSAppHelper

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
    create_file('dir1/test.jpg')
    entry = content_entries('/dir1').first
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

  def expected_content(entry, component, view: true, edit: true, delete: true)
    content = String.new

    content = %(<a href="#{component.view_href}">#{entry.name}</a>) if view
    content << %(\n<a class="edit" href="#{component.edit_href}"></a>) if edit

    if delete
      content << <<~CONTENT
        \n<form class="inline delete" action="#{component.delete_action}" method="post">
          <button class="delete" type="submit"></button>
        </form>
      CONTENT
    end

    content
  end
end
