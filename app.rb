require 'sinatra'
require 'rugged'

get '/:repo/?:type?/?:branch?/?:path?' do
  repo_path = '../slang'

  type = params[:type] || 'tree'
  @branch = params[:branch] || 'master'
  path = params[:path] || '/'

  repo = Rugged::Repository.new(repo_path)

  # TODO: perform the search recursively using the path
  case type
  when 'tree'
    @tree = repo.lookup(repo.branches[@branch].target.tree.oid)
    erb :tree
  when 'blob'
    oid = nil
    @blob = repo.lookup(repo.branches[@branch].target.tree.oid).each do |el|
      if el[:name] == path
        oid = el[:oid]
      end
    end

    @blob_content = repo.lookup(oid).content
    erb :blob
  end
end

__END__

@@ blob
<code>
  <%= @blob_content %>
</code>

@@ tree
<ul>
  <% @tree.each do |element| %>
    <li>
      <a href="/repo/<%= element[:type]%>/<%= @branch %>/<%= element[:name] %>">
        <%= element[:name] %>
      </a>
    </li>
  <% end %>
</ul>
