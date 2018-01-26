defmodule BUPETest.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  setup do
    File.rm_rf(tmp_dir())
    File.mkdir_p!(tmp_dir())
  end

  def tmp_dir do
    Path.expand("../tmp", __DIR__)
  end

  def tmp_dir(path) do
    Path.join(tmp_dir(), path)
  end

  def fixtures_dir do
    Path.expand("../fixtures", __DIR__)
  end

  def fixtures_dir(path) do
    Path.join(fixtures_dir(), path)
  end

  def config do
    files =
      "/30/*.xhtml"
      |> fixtures_dir()
      |> Path.wildcard()

    get_id = fn file -> Path.basename(file, ".xhtml") end

    pages =
      Enum.map(files, fn file ->
        %{href: file, id: get_id.(file), description: file |> get_id.() |> String.capitalize()}
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
end
