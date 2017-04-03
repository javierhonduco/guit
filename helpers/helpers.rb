require_relative './html_helpers'
require_relative './git_helpers'

module Guit
  module Helpers
    include Html
    include Git
  end
end
