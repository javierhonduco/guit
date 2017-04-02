class Guit < Sinatra::Base
  not_found do
    '404'
  end

  # to avoid getting a 500 error
  get '/favicon.ico' do
    ''
  end

  get '/' do
    erb :index
  end

  # Does not work because of emojis :(
  #   http://localhost:4567/rails/blob/%F0%9F%98%85/guides/bug_report_templates/active_record_migrations_master.rb
  get '/:repo/?:type?/?*?' do
    @repo = params[:repo] || 'rails' # TODO: changeme
    @type = params[:type] || 'tree'

    repo = GuitModel.new(@repo)
    @branches = repo.local_branches
    @branch   = repo.branch_from_url(params[:splat].first)
    @path     = repo.path_from_url(params[:splat].first)
    @tags     = repo.tags
    object, @traversed = repo.find_object_by_path(@path.split('/'), @branch)

    # Checks if the requested url exists
    # many bugs here
    whole_path = File.join(@traversed)
    if @path != whole_path && @path != "#{whole_path}/"
      status 404
      return
    end

    if @type == 'tags'
      erb :tags
    else
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
end
