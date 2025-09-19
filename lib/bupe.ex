defmodule BUPE do
  @external_resource "README.md"
  @moduledoc @external_resource
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  @bupe_version Mix.Project.config()[:version]

  @doc """
  Returns the BUPE version (used in templates)
  """
  @spec version :: String.t()
  def version, do: @bupe_version

  @doc ~S"""
  EPUB builder

  ## Options

  * `:memory` - Instead of a file, it will produce a tuple `{file_name, binary()}`. The
    binary is a full zip archive with header and can be extracted with,
    for example, `:zip.unzip/2`.

  ## Example

      iex(1)> files = Enum.map(~w(bacon.xhtml egg.xhtml ham.xhtml), &Path.join("/Users/dev/book", &1))
      ["/Users/dev/book/bacon.xhtml", "/Users/dev/book/egg.xhtml", "/Users/dev/book/ham.xhtml"]
      iex(2)> get_id = &Path.basename(&1, ".xhtml")
      iex(3)> pages = Enum.map(files, fn file ->
      ...(3)>   %BUPE.Item{href: file, id: get_id.(file), description: file |> get_id.() |> String.capitalize()}
      ...(3)> end)
      iex(4)> config = %{
      ...(4)>  title: "Sample",
      ...(4)>  language: "en",
      ...(4)>  creator: "John Doe",
      ...(4)>  publisher: "Sample",
      ...(4)>  date: "2016-06-23T06:00:00Z",
      ...(4)>  unique_identifier: "EXAMPLE",
      ...(4)>  identifier: "http://example.com/book/jdoe/1",
      ...(4)>  pages: pages
      ...(4)> }
      iex(5)> BUPE.Config.new(config)

  Once you have the `%Bupe.Config{}` struct ready, you can execute `BUPE.build/3`, e.g., `BUPE.build(config, "example.epub")`
  """
  defdelegate build(config, output, options \\ []), to: BUPE.Builder, as: :run

  @doc ~S"""
  An [EPUB 3][EPUB] conforming parser. This implementation should support also
  EPUB 2 too.

  ## Example

      BUPE.parse("sample.epub")

  [EPUB]: https://idpf.org/epub/301/spec/epub-overview.html
  """
  defdelegate parse(epub_file), to: BUPE.Parser, as: :run
end
