defmodule BUPETest.Case do
  # credo:disable-for-this-file Credo.Check.Readability.ModuleDoc
  use ExUnit.CaseTemplate

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  def fixtures_dir, do: Path.expand("../fixtures", __DIR__)

  def fixtures_dir(path), do: Path.join(fixtures_dir(), path)

  def config do
    files =
      "/30/*.xhtml"
      |> fixtures_dir()
      |> Path.wildcard()

    get_id = fn file -> Path.basename(file, ".xhtml") end

    pages =
      Enum.map(files, fn file ->
        %BUPE.Item{
          href: file,
          id: get_id.(file),
          description: file |> get_id.() |> String.capitalize()
        }
      end)

    %BUPE.Config{
      title: "Sample",
      language: "en",
      creator: "John Doe",
      publisher: "Sample",
      unique_identifier: "EXAMPLE",
      pages: pages
    }
  end

  def build_epub(path, entries \\ []) when is_list(entries) do
    files =
      [{"mimetype", "application/epub+zip"}]
      |> Enum.concat(entries)
      |> Enum.map(fn {name, content} ->
        {to_charlist(name), content}
      end)

    case :zip.create(to_charlist(path), files) do
      {:ok, _} -> path
      {:error, reason} -> raise reason
    end
  end
end
