defmodule BUPE.Builder.Templates do
  @moduledoc false

  require EEx

  Application.app_dir(:bupe)
  |> Path.join("priv/bupe/builder/templates/media-types.txt")
  |> File.stream!()
  |> Enum.each(fn(line) ->
    [extension, media] = line |> String.trim() |> String.split(",")

    def media_type("." <> unquote(extension)) do
      unquote(media)
    end
  end)

  def media_type(_), do: nil

  templates = [
    content_template: [:config],
    ncx_template: [:config],
    nav_template: [:config],
    title_template: [:config]
  ]

  Enum.each templates, fn({name, args}) ->
    filename = Path.expand("templates/#{name}.eex", __DIR__)
    @doc false
    EEx.function_from_file :def, name, filename, args
  end
end
