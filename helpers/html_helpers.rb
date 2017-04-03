module Guit
  module Helpers
    module Html
      extend self

      def generate_path_link(paths)
        link = []
        paths.each do |path|
          link << path
          yield File.join(link), path
        end
      end

      def humanize_type(input)
        case input
        when :tree
          'd'
        when :blob
          'f'
        when :commit
          'c'
        end
      end
    end
  end
end
