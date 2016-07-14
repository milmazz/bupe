<?xml version='1.0' encoding='utf-8'?>
<ncx xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
     xmlns="http://www.daisy.org/z3986/2005/ncx/"
     version="2005-1"
     xml:lang="<%= config.lang %>">
  <head>
    <meta name="dtb:uid" content="<%= config.uid %>" />
    <meta name="dtb:depth" content="1" />
    <meta name="dtb:totalPageCount" content="0" />
    <meta name="dtb:maxPageNumber" content="0" />
  </head>
  <docTitle>
    <text><%= config.title %></text>
  </docTitle>
  <navMap>
    <navPoint id="navpoint-1" playOrder="1">
      <navLabel>
        <text>Book cover</text>
      </navLabel>
      <content src="title.html" />
    </navPoint>
    <%= for {node, index} <- Enum.with_index(config.nav) do %>
    <navPoint id="<%= node.id %>" playOrder="<%= index + 2 %>">
      <navLabel>
        <text><%= node.label %></text>
      </navLabel>
      <content src="<%= node.content %>" />
    </navPoint>
    <% end %>
  </navMap>
</ncx>