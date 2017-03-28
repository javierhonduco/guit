def parse_branch_and_path(splatted, branches, default_branch = 'master', default_path = '/')
  # e.g:
  # [master, javier/test, fixes/at/github]
  # [master, fixes/at/github]

  # mmmnnnhh not sure this is a good idea or even necessary

  longest_branch = ''

  branches.each do |branch|
    current_substring = splatted[branch]

    # mmmmnh instead of checking in the ifs
    next if current_substring.nil?

    if current_substring.length > longest_branch.length
      longest_branch = current_substring
    end
  end

  path = splatted[longest_branch.length..-1]

  # deharcode defaults
  branch = longest_branch.empty? ? default_branch : longest_branch
  path = path.empty? ? default_path : path
  [branch, path]
end

def find_object_tree(repo, root_oid, path_splitted)
  current_tree = repo.lookup(root_oid)
  traversed_path = ['/']

  # we are not checking if we found the searched element
  path_splitted.each do |path|
    current_tree.each do |element|
      # Subrepos are problematic
      # And this is CPU & IO heavy. Cache me maybe?
      # problems: cache should be invalidates on force pushes and...?
      if element[:name] == path
        puts "traversing el:#{element[:name]}, type:{element[:type]}"

        # element could be a blob and this would fail.
        current_tree = repo.lookup(element[:oid])
        traversed_path << element[:name]
      end
    end
  end

  [current_tree, traversed_path]
end
