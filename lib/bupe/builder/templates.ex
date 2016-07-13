defmodule BUPE.Builder.Templates do
  @moduledoc """
  Handle all template interfaces for the EPUB Builder
  """

  require EEx

  templates = [
    content_template: [:config],
    toc_template: [:config],
    nav_template: [:config],
    title_template: [:config]
  ]

  Enum.each templates, fn({name, args}) ->
    filename = Path.expand("templates/#{name}.eex", __DIR__)
    @doc false
    EEx.function_from_file :def, name, filename, args
  end
end
