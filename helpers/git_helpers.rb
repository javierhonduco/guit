module Guit
  module Helpers
    module Git
      extend self

      def parse_branch_and_path(splatted, branches, default_branch = 'master', default_path = '/')
        # e.g:
        # [master, javier/test, fixes/at/github]
        # [master, fixes/at/github]

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

        branch = longest_branch.empty? ? default_branch : longest_branch
        path = path.empty? ? default_path : path

        [branch, path]
      end

      def find_object_tree(repo, root_oid, path_splitted)
        current_tree = repo.lookup(root_oid)
        traversed_path = ['/']

        # This is CPU & IO heavy. We are not caching as it
        # introduces more complexity and the benefit in this
        # particular case is not as big.
        path_splitted.each do |path|
          current_tree.each do |element|
            next unless element[:name] == path

            current_tree = repo.lookup(element[:oid])
            traversed_path << element[:name]

            # We have reached the end
            if current_tree.type == :blob
              return [current_tree, traversed_path]
            end
          end
        end

        [current_tree, traversed_path]
      end
    end
  end
end
