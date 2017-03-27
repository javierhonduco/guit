require 'sinatra'
require 'rugged'

DEFAULT_REPO_PATH = '..'

def parse_branch_and_path(splatted, branches)
  # e.g:
  # [master, javier/test, fixes/at/github]
  # [master, fixes/at/github]

  if splatted == ""
    return ['master', '/']
  end

  longest_substring = ''

  branches.each do |branch|
    current_substring = splatted[branch]
    if !current_substring.nil? && current_substring.length > longest_substring.length
      longest_substring = current_substring
    end
  end

  branch = longest_substring
  path = splatted[branch.length..-1]

  [branch || 'master', path || '/']
end

def find_object(repo, root_oid, path_splitted)
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

        current_tree = repo.lookup(element[:oid])
        traversed_path << element[:name]
      end
    end
  end

  puts "entire traversal: #{File.join(traversed_path)}"
  [current_tree, traversed_path]
end

get '/' do
  '<a href="/rails">go to rails</a>'
end

get '/:repo/?:type?/?*?' do
  @repo = params[:repo] || 'rails' # TODO: changeme
  @type = params[:type] || 'tree'

  repo = Rugged::Repository.new("#{DEFAULT_REPO_PATH}/#{@repo}")
  @branches = repo.branches.each_name(:local).sort

  @branch, path = parse_branch_and_path(params[:splat].first, @branches)
  puts "this is cools #{@branch}:#{path}"

  root_oid = repo.branches[@branch].target.tree.oid

  object, @traversed = find_object(repo, root_oid, path.split('/'))

  case object.type
  when :tree
    @tree = object
    erb :tree
  when :blob
    @blob = object
    erb :blob
  end
end

__END__

@@ blob
<code style="white-space:pre-wrap;">
<%= @blob.content %>
</code>

@@ tree
<select <% if @branches.size == 1 %> disabled <% end %> onchange="location = '<%= File.join(['/', @repo, @type.to_s]) %>/'+this.value+'<%= File.join(@traversed) %>';">
  <% @branches.each do |branch| %>
    <option name="<%= branch %>" <% if branch == @branch %> selected <% end %>><%= branch %></option>
  <% end %>
</select>
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
      <% unless element[:type] == :commit %>
        <a href="<%= File.join(['/', @repo, element[:type].to_s, @branch, @traversed, element[:name]]) %>">
      <% end %>
      <%= element[:name] %>
      <% unless element[:type] == :commit %>
        </a>
      <% end %>
    </li>
  <% end %>
</ul>
