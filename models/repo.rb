module Guit
  module Models
    class Repo
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

      def references_names
        local_branches + tags.map { |tag| tag.name.split('/').last }
      end

      def parse_url(url)
        @parse_url ||= Helpers::Git.parse_branch_and_path(url, references_names)
      end

      def oid_for_object(object)
        object = repo.references.each("*/*/#{object}").first.target

        if object.type == :tag
          object.target.tree.oid
        else
          object.tree.oid
        end
      end

      def find_object_by_path(path, object)
        Helpers::Git.find_object_tree(repo, oid_for_object(object), path)
      end

      def commits
      end
    end
  end
end
