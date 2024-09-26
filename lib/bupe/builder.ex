defmodule BUPE.Builder do
  @moduledoc ~S"""
  Elixir EPUB generator

  ## Example

      iex(1)> files = "~/book/*.xhtml" |> Path.expand() |> Path.wildcard()
      ["/Users/dev/book/bacon.xhtml", "/Users/dev/book/egg.xhtml", "/Users/dev/book/ham.xhtml"]
      iex(2)> get_id = fn file -> Path.basename(file, ".xhtml") end
      #Function<6.99386804/1 in :erl_eval.expr/5>
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
      iex(4)> config = %BUPE.Config{
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
      iex(6)> BUPE.Builder.run(config, "example.epub")
      {:ok, '/Users/dev/example.epub'}

  """
  alias BUPE.{Builder.Templates, Config, Item, Util}

  @mimetype "application/epub+zip"
  @container_template File.read!(Path.expand("builder/templates/assets/container.xml", __DIR__))
  @display_options File.read!(
                     Path.expand(
                       "builder/templates/assets/com.apple.ibooks.display-options.xml",
                       __DIR__
                     )
                   )
  @stylesheet File.read!(Path.expand("builder/templates/css/stylesheet.css", __DIR__))

  @doc """
  Generates an EPUB v3 document
  """
  @spec run(Config.t(), Path.t(), Keyword.t()) :: {:ok, String.t()} | {:error, String.t()}
  def run(config, name, options \\ []) do
    name = Path.expand(name)

    config
    |> normalize_config()
    |> generate_assets(assets())
    |> generate_package()
    |> generate_ncx()
    |> generate_nav()
    |> generate_title()
    |> generate_content()
    |> generate_epub(name, options)
  end

  defp normalize_config(config) do
    config =
      config
      |> modified_date()
      |> normalize_assets()
      |> check_identifier()
      |> check_files_extension()
      |> check_unique_identifier()

    %{files: [], details: config}
  end

  defp normalize_assets(config) do
    [pages, styles, scripts, images] =
      for asset <- ~w(pages styles scripts images)a do
        config
        |> Map.get(asset)
        |> transform_assets()
      end

    %{config | pages: pages, styles: styles, scripts: scripts, images: images}
  end

  defp transform_assets([]), do: []
  defp transform_assets(assets), do: Enum.map(assets, &transform_asset/1)

  defp transform_asset(%Item{} = asset), do: Item.normalize(asset)
  defp transform_asset(asset) when is_binary(asset), do: Item.from_string(asset)

  # Package definition builder.
  #
  # According to the EPUB specification, the *Package Document* carries
  # bibliographic and structural metadata about an EPUB Publication, and is thus
  # the primary source of information about how to process and display it.
  #
  # The `package` element is the root container of the Package Document and
  # encapsulates Publication metadata and resource information.
  defp generate_package(config) do
    content = Templates.content_template(config.details)

    %{config | files: [{~c"OEBPS/content.opf", content} | config.files]}
  end

  # Navigation Center eXtended definition
  #
  # Keep in mind that the EPUB Navigation Document supersedes this definition.
  # According to the EPUB specification:
  #
  # > EPUB 3 Publications may include an NCX (as defined in OPF 2.0.1) for EPUB
  # > 2 Reading System forwards compatibility purposes, but EPUB 3 Reading
  # > Systems must ignore the NCX.
  defp generate_ncx(config) do
    content = Templates.ncx_template(config.details)

    %{config | files: [{~c"OEBPS/toc.ncx", content} | config.files]}
  end

  # Navigation Document Definition
  #
  # The TOC nav element defines the primary navigation hierarchy of the document.
  # It conceptually corresponds to a table of contents in a printed work.
  #
  # See [EPUB Navigation Document Definition][nav] for more information.
  #
  # [nav]: http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def
  defp generate_nav(config) do
    if config.details.version == "3.0" do
      content = Templates.nav_template(config.details)

      %{config | files: [{~c"OEBPS/nav.xhtml", content} | config.files]}
    else
      config
    end
  end

  # Cover page definition for the EPUB document
  defp generate_title(config) do
    if config.details.cover do
      content = Templates.title_template(config.details)
      %{config | files: [{~c"OEBPS/title.xhtml", content} | config.files]}
    else
      config
    end
  end

  defp generate_content(config) do
    sources =
      config.details.pages ++
        config.details.styles ++ config.details.scripts ++ config.details.images

    sources
    |> Enum.map(fn source ->
      content = File.read!(source.href)
      path = "OEBPS/content" |> Path.join(Path.basename(source.href)) |> String.to_charlist()

      {path, content}
    end)
    |> Enum.concat(config.files)
  end

  defp generate_epub(files, name, options) do
    opts = [
      compress: [
        ~c".css",
        ~c".js",
        ~c".html",
        ~c".xhtml",
        ~c".ncx",
        ~c".opf",
        ~c".jpg",
        ~c".png",
        ~c".xml"
      ]
    ]

    opts = if Enum.find(options, &(&1 == :memory)), do: [:memory | opts], else: opts

    :zip.create(String.to_charlist(name), [{~c"mimetype", @mimetype} | files], opts)
  end

  ## Helpers
  defp modified_date(%{modified: nil} = config) do
    dt = DateTime.utc_now() |> Map.put(:microsecond, {0, 0}) |> DateTime.to_iso8601()
    Map.put(config, :modified, dt)
  end

  # credo:disable-for-next-line Credo.Check.Design.TagTODO
  # TODO: Check if format is compatible with ISO8601
  defp modified_date(config), do: config

  defp check_identifier(%{identifier: nil} = config) do
    identifier = "urn:uuid:#{Util.uuid4()}"
    Map.put(config, :identifier, identifier)
  end

  defp check_identifier(config), do: config

  defp check_files_extension(%{version: "3.0"} = config) do
    if invalid_files?(config.pages, [".xhtml"]) do
      raise BUPE.InvalidExtensionName,
            "XHTML Content Document file names should have the extension '.xhtml'."
    end

    config
  end

  defp check_files_extension(%{version: "2.0"} = config) do
    if invalid_files?(config.pages, [".html", ".htm", ".xhtml"]) do
      raise BUPE.InvalidExtensionName,
            "invalid file extension for HTML file, expected '.html', '.htm' or '.xhtml'"
    end

    config
  end

  defp check_files_extension(_config), do: raise(BUPE.InvalidVersion)

  defp check_unique_identifier(%{unique_identifier: nil} = config),
    do: Map.put(config, :unique_identifier, "BUPE")

  defp check_unique_identifier(config), do: config

  defp invalid_files?(files, extensions) do
    Enum.filter(files, &((&1.href |> Path.extname() |> String.downcase()) in extensions)) != files
  end

  defp assets do
    [
      [content: @stylesheet, dir: "OEBPS/css", filename: "stylesheet.css"],
      [content: @container_template, dir: "META-INF", filename: "container.xml"],
      [
        content: @display_options,
        dir: "META-INF",
        filename: "com.apple.ibooks.display-options.xml"
      ]
    ]
  end

  defp generate_assets(config, assets) do
    files =
      Enum.into(assets, config.files, fn asset ->
        {asset[:dir] |> Path.join(asset[:filename]) |> String.to_charlist(), asset[:content]}
      end)

    %{config | files: files}
  end
end
