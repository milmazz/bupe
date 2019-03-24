defmodule BUPE.Builder.Templates do
  @moduledoc false

  require EEx

  defp get_content_path(%{href: href}) do
    path = Path.basename(href)
    "content/#{path}"
  end

  templates = [
    content_template: [:config],
    ncx_template: [:config],
    nav_template: [:config],
    title_template: [:config]
  ]

  Enum.each(templates, fn {name, args} ->
    filename = Path.expand("templates/#{name}.eex", __DIR__)
    @doc false
    EEx.function_from_file(:def, name, filename, args)
  end)
end
