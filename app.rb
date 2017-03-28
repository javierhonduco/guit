require 'sinatra/base'
require 'rugged'
require './config'
require './helpers'
require './git_helpers'

class Guit < Sinatra::Base
  not_found do
    '404'
  end

  # to avoid getting a 500 error
  get '/favicon.ico' do
    ''
  end

  get '/' do
    '<a href="/rails">go to rails</a>'
  end

  # does not work :( http://localhost:4567/rails/blob/%F0%9F%98%85/guides/bug_report_templates/active_record_migrations_master.rb
  # bc of emojis
  get '/:repo/?:type?/?*?' do
    @repo = params[:repo] || 'rails' # TODO: changeme
    # i don't really understand why is this needed
    @type = params[:type] || 'tree'

    repo = Rugged::Repository.new("#{DEFAULT_REPO_PATH}/#{@repo}")
    @branches = repo.branches.each_name(:local).sort

    @branch, @path = parse_branch_and_path(params[:splat].first, @branches)
    puts "this is cools #{@branch}:#{@path}"

    root_oid = repo.branches[@branch].target.tree.oid

    object, @traversed = find_object_tree(repo, root_oid, @path.split('/'))

    puts "path_split: #{@path}; traversed:#{File.join(@traversed)}"
    if @path != "#{File.join(@traversed)}/" && @path != "#{File.join(@traversed)}"
      status 404
      return
    end

    case object.type
    when :tree
      @tree = object
      erb :tree
    when :blob
      @blob = object
      erb :blob
    end
  end
end
