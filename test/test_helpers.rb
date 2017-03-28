require_relative './test_helper'
require_relative '../helpers.rb'

class TestHelpers < Minitest::Test
  def test_humanize_git_type
    assert_equal 'd', humanize_type(:tree)
    assert_equal 'f', humanize_type(:blob)
    assert_equal 'c', humanize_type(:commit)
  end

  def test_path_generator_empty
    assert_equal [], generate_path_link([])
  end

  def test_path_generator_basic
    expected = [['', ''], ['/rails', 'rails'], ['/rails/activerecord', 'activerecord'], ['/rails/activerecord/test', 'test']]
    computed = []
    paths = '/rails/activerecord/test'.split '/'
    generate_path_link(paths) do |link, path|
      computed << [link, path]
    end

    assert_equal expected, computed
  end
end
