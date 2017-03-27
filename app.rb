require 'sinatra'
require 'rugged'

DEFAULT_REPO_PATH = '..'

not_found do
  '404'
end

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

get '/' do
  '<a href="/rails">go to rails</a>'
end

get '/:repo/?:type?/?*?' do
  @repo = params[:repo] || 'rails' # TODO: changeme
  # i don't really understand why is this needed
  #
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

# does not work :( http://localhost:4567/rails/blob/%F0%9F%98%85/guides/bug_report_templates/active_record_migrations_master.rb
# bc of emojis

__END__

@@ blob
<code style="white-space:pre-wrap;">
<%= @blob.content %>
</code>

@@ tree
<div>
  <select <% if @branches.size == 1 %> disabled <% end %> onchange="location = '<%= File.join(['/', @repo, @type.to_s]) %>/'+this.value+'<%= File.join(@traversed) %>';">
    <% @branches.each do |branch| %>
      <option name="<%= branch %>" <% if branch == @branch %> selected <% end %>><%= branch %></option>
    <% end %>
  </select>

    <% generate_path_link(@path.split('/')) do |link, path| %>
      <a href="<%= File.join(['/', @repo, @type.to_s, @branch, link])%>"><%= path %>/</a>
    <% end %>

</div>

<ul>
  <% if File.join(@traversed) != '/' %>
    <li>
      <a href="<%= File.join(['/', @repo, @type.to_s, @branch, @traversed[0..-2]]) %>">
        ..
      </a>
    </li>
  <% end %>
  <% @tree.each do |element| %>
    <li>
      <code>
        <%= humanize_type(element[:type]) %>
        <% unless element[:type] == :commit %>
          <a href="<%= File.join(['/', @repo, element[:type].to_s, @branch, @traversed, element[:name]]) %>">
        <% end %>
        <%= element[:name] %>
        <% unless element[:type] == :commit %>
          </a>
        <% end %>
      </code>
    </li>
  <% end %>
</ul>
