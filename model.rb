class GuitModel
  attr_accessor :repo

  def initialize(repo_name)
    full_repo_path = "#{DEFAULT_REPO_PATH}/#{repo_name}"
    @repo = Rugged::Repository.new(full_repo_path)
  end

  def local_branches
    repo.branches.each_name(:local).sort
  end

  def branch_from_url(url)
    parse_url(url).first
  end

  def path_from_url(url)
    parse_url(url).last
  end

  def tags
    repo.references.each('refs/tags/*')
  end

  def parse_url(url)
    @parse_url ||= parse_branch_and_path(url,local_branches)
  end

  def oid_for_branch(branch)
     repo.branches[branch].target.tree.oid
  end

  def find_object_by_path(path, branch)
    find_object_tree(repo, oid_for_branch(branch), path)
  end
end
