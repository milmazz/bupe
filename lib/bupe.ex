defmodule BUPE do
  @moduledoc """
  EPUB generator and parser.
  """

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
      iex(2)> get_id = fn file -> Path.basename(file, ".xhtml") end
      iex(3)> pages = Enum.map(files, fn file ->
      ...(3)>   %BUPE.Item{href: file, id: get_id.(file), description: file |> get_id.() |> String.capitalize()}
      ...(3)> end)
      [
        %BUPE.Item{
          description: "Bacon",
          duration: nil,
          fallback: nil,
          href: "/Users/dev/book/bacon.xhtml",
          id: "bacon",
          media_overlay: nil,
          media_type: nil,
          properties: nil
        },
        %BUPE.Item{
          description: "Egg",
          duration: nil,
          fallback: nil,
          href: "/Users/dev/book/egg.xhtml",
          id: "egg",
          media_overlay: nil,
          media_type: nil,
          properties: nil
        },
        %BUPE.Item{
          description: "Ham",
          duration: nil,
          fallback: nil,
          href: "/Users/dev/book/ham.xhtml",
          id: "ham",
          media_overlay: nil,
          media_type: nil,
          properties: nil
        }
      ]
      iex(4)> %BUPE.Config{
      ...(4)>  title: "Sample",
      ...(4)>  language: "en",
      ...(4)>  creator: "John Doe",
      ...(4)>  publisher: "Sample",
      ...(4)>  date: "2016-06-23T06:00:00Z",
      ...(4)>  unique_identifier: "EXAMPLE",
      ...(4)>  identifier: "http://example.com/book/jdoe/1",
      ...(4)>  pages: pages
      ...(4)> }
      %BUPE.Config{
        audio: [],
        contributor: nil,
        cover: true,
        coverage: nil,
        creator: "John Doe",
        date: "2016-06-23T06:00:00Z",
        description: nil,
        fonts: [],
        format: nil,
        identifier: "http://example.com/book/jdoe/1",
        images: [],
        language: "en",
        logo: nil,
        modified: nil,
        nav: [],
        pages: [
          %BUPE.Item{
            description: "Bacon",
            duration: nil,
            fallback: nil,
            href: "/Users/dev/book/bacon.xhtml",
            id: "bacon",
            media_overlay: nil,
            media_type: nil,
            properties: nil
          },
          %BUPE.Item{
            description: "Egg",
            duration: nil,
            fallback: nil,
            href: "/Users/dev/book/egg.xhtml",
            id: "egg",
            media_overlay: nil,
            media_type: nil,
            properties: nil
          },
          %BUPE.Item{
            description: "Ham",
            duration: nil,
            fallback: nil,
            href: "/Users/dev/book/ham.xhtml",
            id: "ham",
            media_overlay: nil,
            media_type: nil,
            properties: nil
          }
        ],
        publisher: "Sample",
        relation: nil,
        rights: nil,
        scripts: [],
        source: nil,
        styles: [],
        subject: nil,
        title: "Sample",
        type: nil,
        unique_identifier: "EXAMPLE",
        version: "3.0"
      }

  Once you have the `%Bupe.Config{}` struct ready, you can execute `BUPE.build/3`, e.g., `BUPE.build(config, "example.epub")`
  """
  defdelegate build(config, output, options \\ []), to: BUPE.Builder, as: :run

  @doc ~S"""
  An [EPUB 3][EPUB] conforming parser. This implementation should support also
  EPUB 2 too.

  ## Example

      BUPE.parse("sample.epub")
      #=> %BUPE.Config{
        creator: "John Doe",
        nav: [
          %{idref: "ode-to-bacon"},
          %{idref: "ode-to-ham"},
          %{idref: "ode-to-egg"}
        ],
        pages: [
          %BUPE.Item{
            duration: nil,
            fallback: nil,
            href: "bacon.xhtml",
            id: "ode-to-bacon",
            media_overlay: nil,
            media_type: "application/xhtml+xml",
            description: nil,
            properties: "scripted",
            content: "<!DOCTYPE html>\n...",
          }
       ],
        styles: [
          %BUPE.Item{href: "stylesheet.css", id: "styles", "media-type": "text/css", content: "..."}
        ],
        title: "Sample",
        unique_identifier: "EXAMPLE",
        version: "3.0"
      }

  [EPUB]: http://www.idpf.org/epub3/latest/overview
  """
  defdelegate parse(epub_file), to: BUPE.Parser, as: :run
end
