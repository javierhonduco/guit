require_relative './test_helper'
require_relative '../helpers/git_helpers.rb'

class TestGitHelpers < Minitest::Test
  include Guit::Helpers::Git

  def test_parse_branch_basic
    splatted = 'master/activesupport/README.rdoc'
    branches = ['master']

    result = parse_branch_and_path(splatted, branches)
    assert_equal ['master', '/activesupport/README.rdoc'], result
  end

  def test_parse_branch_with_slash
    splatted = 'javier/activesupport/activesupport/README.rdoc'
    branches = ['javier/activesupport']

    result = parse_branch_and_path(splatted, branches)
    assert_equal ['javier/activesupport', '/activesupport/README.rdoc'], result
  end

  def test_parse_branch_with_multiple_slashes
    splatted = 'javier/activesupport/a/activesupport/README.rdoc'
    branches = ['javier/activesupport/a']

    result = parse_branch_and_path(splatted, branches)
    assert_equal ['javier/activesupport/a', '/activesupport/README.rdoc'], result
  end

  def test_git_traverser_test_ultra_super_really_basic
    repo = MiniTest::Mock.new
    repo.expect(:lookup, [], [:root_oid])

    root_oid = :root_oid
    path_splitted = '/'.split '/'
    current_tree, traversed_path = find_object_tree(repo, root_oid, path_splitted)

    assert [], current_tree
    assert ['/'], traversed_path

    assert repo.verify
  end
end
