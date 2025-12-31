defmodule BUPE.Builder do
  @moduledoc false
  alias BUPE.{Builder.Templates, Config, Item, Util}

  @spec run(Config.t(), Path.t(), Keyword.t()) ::
          {:ok, String.t()} | {:ok, {String.t(), binary()}} | {:error, String.t()}
  def run(config, name, options \\ []) do
    name = Path.expand(name)

    config
    |> normalize_config()
    |> generate_assets()
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
  defp transform_assets(assets), do: Enum.map(assets, &Item.normalize/1)

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

  defp generate_content(%{details: details} = config) do
    sources =
      Enum.concat([
        details.pages,
        details.styles,
        details.scripts,
        details.images
      ])

    sources
    |> Enum.map(fn source ->
      content = File.read!(source.href)

      path =
        "OEBPS/content"
        |> Path.join(Path.basename(source.href))
        |> String.to_charlist()

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
      ],
      extra: []
    ]

    opts = if Enum.find(options, &(&1 == :memory)), do: [:memory | opts], else: opts

    :zip.create(String.to_charlist(name), [{~c"mimetype", "application/epub+zip"} | files], opts)
  end

  ## Helpers
  defp modified_date(%{modified: nil} = config) do
    dt = DateTime.utc_now() |> Map.put(:microsecond, {0, 0}) |> DateTime.to_iso8601()
    Map.put(config, :modified, dt)
  end

  defp modified_date(%{modified: modified} = config) when is_binary(modified) do
    case DateTime.from_iso8601(modified) do
      {:ok, _, 0} -> config
      _ -> raise BUPE.InvalidDate
    end
  end

  defp modified_date(_config), do: raise(BUPE.InvalidDate)

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

  defp generate_assets(config) do
    files =
      Enum.into(
        [
          {~c"OEBPS/css/stylesheet.css", "builder/templates/css/stylesheet.css"},
          {~c"META-INF/container.xml", "builder/templates/assets/container.xml"},
          {~c"META-INF/com.apple.ibooks.display-options.xml",
           "builder/templates/assets/com.apple.ibooks.display-options.xml"}
        ],
        config.files,
        fn {dest, content_path} ->
          content = content_path |> Path.expand(__DIR__) |> File.read!()
          {dest, content}
        end
      )

    %{config | files: files}
  end
end
