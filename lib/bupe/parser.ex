defmodule BUPE.Parser do
  @moduledoc false

  def run(<<0x04034B50::little-size(32), _::binary>> = epub), do: parse(epub)

  @spec run(Path.t()) :: BUPE.Config.t() | no_return
  def run(path) when is_binary(path) do
    path = path |> Path.expand() |> String.to_charlist()

    with :ok <- check_file(path),
         :ok <- check_extension(path) do
      parse(path)
    end
  end

  defp parse(epub) do
    with :ok <- check_mimetype(epub),
         {:ok, root_file} <- find_rootfile(epub),
         {:ok, xml} <- parse_xml_file(epub, root_file) do
      config =
        Enum.reduce(
          ~w(metadata manifest navigation extras toc)a,
          %BUPE.Config{title: nil, pages: nil},
          &parse_xml(&2, xml, &1)
        )

      %{
        config
        | pages: extract_item_content(epub, root_file, config.pages || []),
          images: extract_item_content(epub, root_file, config.images || []),
          styles: extract_item_content(epub, root_file, config.styles || []),
          scripts: extract_item_content(epub, root_file, config.scripts || []),
          toc: extract_item_content(epub, root_file, config.toc || [])
      }
    end
  end

  defp extract_item_content(epub, root_file, items) do
    root_dir = Path.dirname(root_file)
    root_dir = if root_dir == ".", do: "", else: root_dir

    item_paths = Enum.map(items, &Path.join([root_dir, &1.href]))

    content =
      epub
      |> extract_files(item_paths)
      |> Map.new(fn {path, content} ->
        {Path.relative_to(path, root_dir), content}
      end)

    normalize_targets = %{
      :"media-overlay" => :media_overlay,
      :"media-type" => :media_type
    }

    normalize_keys = Map.keys(normalize_targets)

    Enum.map(items, fn %{href: href} = item ->
      {tmp, item} = Map.split(item, normalize_keys)

      item =
        tmp
        |> Map.new(fn {k, v} ->
          {Map.get(normalize_targets, k), v}
        end)
        |> Map.merge(item)
        |> Map.put(:content, Map.get(content, href, ""))

      struct(BUPE.Item, item)
    end)
  end

  defp check_file(epub) do
    if File.exists?(epub) do
      :ok
    else
      raise ArgumentError, "file #{epub} does not exists"
    end
  end

  defp check_extension(epub) do
    if epub |> Path.extname() |> String.downcase() == ".epub" do
      :ok
    else
      raise ArgumentError, "file #{epub} does not have an '.epub' extension"
    end
  end

  defp check_mimetype(epub) do
    if epub |> extract_files(["mimetype"]) |> mimetype_valid?() do
      :ok
    else
      raise "invalid mimetype, must be 'application/epub+zip'"
    end
  end

  defp mimetype_valid?([{~c"mimetype", "application/epub+zip"}]), do: true
  defp mimetype_valid?(_), do: false

  defp find_rootfile(epub) do
    container = ~c"META-INF/container.xml"
    [{^container, content}] = extract_files(epub, [container])

    full_path =
      Regex.named_captures(~r/<rootfile\s.*full-path="(?<full_path>[^"]+)"\s/, content)[
        "full_path"
      ]

    if full_path do
      {:ok, full_path}
    else
      raise "could not find rootfile in #{container}"
    end
  end

  defp parse_xml_file(epub, file) do
    file = String.to_charlist(file)
    [{^file, content}] = extract_files(epub, [file])

    {xml, _rest} = content |> :erlang.bitstring_to_list() |> :xmerl_scan.string()

    {:ok, xml}
  end

  defp parse_xml(config, xml, :extras) do
    %{
      config
      | language: find_language(xml),
        version: find_xml(xml, "/package/@version"),
        unique_identifier: find_xml(xml, "/package/@unique-identifier")
    }
  end

  defp parse_xml(config, xml, :manifest) do
    manifest =
      Map.new(
        [
          images: ["image/jpeg", "image/gif", "image/png", "image/svg+xml"],
          scripts: "application/javascript",
          styles: "text/css",
          pages: "application/xhtml+xml",
          audio: ["audio/mpeg", "audio/mp4"],
          fonts: [
            "application/font-sfnt",
            "application/font-woff",
            "font/woff2",
            "application/vnd.ms-opentype"
          ]
        ],
        fn {key, pattern} ->
          {key, find_manifest(xml, pattern)}
        end
      )

    struct(config, manifest)
  end

  defp parse_xml(config, xml, :metadata) do
    metadata =
      Map.new(
        ~w(
          title
          identifier
          creator
          contributor
          date
          source
          type
          description
          format
          coverage
          publisher
          relation
          rights
          subject
      )a,
        fn key -> {key, find_metadata(xml, to_string(key))} end
      )

    config = struct(config, metadata)

    %{
      config
      | modified: find_metadata_property(xml, "dcterms:modified"),
        source: config.source || find_metadata_property(xml, "dcterms:source")
    }
  end

  defp parse_xml(%BUPE.Config{version: "3.0"} = config, xml, :toc) do
    case find_xml(xml, "/package/manifest/item[contains(@properties,'nav')]", :element) do
      [toc_item] ->
        %{config | toc: [toc_item]}

      [] ->
        raise "no nav item with properties containing nav in manifest"

      items when is_list(items) ->
        raise "there should be exactly one item with properties containing nav in manifest, found #{length(items)}"
    end
  end

  defp parse_xml(%BUPE.Config{version: "2.0"} = config, xml, :toc) do
    with toc_id <- find_xml(xml, "/package/spine/@toc"),
         [toc_item] <- find_xml(xml, "/package/manifest/item[@id='#{toc_id}']", :element) do
      %{config | toc: [toc_item]}
    else
      [] ->
        raise "no toc item found in manifest"

      items when is_list(items) ->
        raise "there should be exactly one toc item in manifest, found #{length(items)}"
    end
  end

  defp parse_xml(_, _, :toc) do
    raise "cannot parse navigation information, because no version number is found in config.version"
  end

  defp parse_xml(config, xml, :navigation) do
    %{config | nav: find_xml(xml, "/package/spine/*", :element)}
  end

  defp extract_files(archive, files) when is_list(files) do
    file_list = Enum.map(files, &if(is_binary(&1), do: String.to_charlist(&1), else: &1))

    case :zip.extract(archive, [{:file_list, file_list}, :memory]) do
      {:ok, content} ->
        content

      {:error, reason} ->
        raise reason
    end
  end

  defp find_metadata(xml, meta) do
    find_xml(xml, "/package/metadata/dc:#{meta}/text()", :text)
  end

  defp find_metadata_property(xml, property),
    do: find_xml(xml, "/package/metadata/meta[contains(@property, '#{property}')]/text()", :text)

  defp find_manifest(xml, media_types) when is_list(media_types) do
    filter = Enum.map_join(media_types, " or ", fn type -> "@media-type='#{type}'" end)

    find_xml(xml, "/package/manifest/item[#{filter}]", :element)
  end

  defp find_manifest(xml, media_type), do: find_manifest(xml, [media_type])

  defp find_xml(xml, filter, type \\ :attribute)

  defp find_xml(xml, filter, :attribute),
    do: filter |> xpath_string(xml) |> transform()

  defp find_xml(xml, filter, type),
    do: filter |> xpath_string(xml) |> transform(type)

  defp find_language(xml) do
    find_metadata(xml, "language") || xpath_string("/package/@xml:lang", xml) |> transform()
  end

  defp xpath_string(xpath, xml) do
    xpath
    |> String.to_charlist()
    |> :xmerl_xpath.string(xml)
  end

  defp transform({
         :xmlElement,
         _name,
         _expanded_name,
         _nsinfo,
         _namespace,
         _parents,
         _pos,
         attributes,
         _content,
         _language,
         _xmlbase,
         :undeclared
       }) do
    Map.new(attributes, fn {:xmlAttribute, name, _, _, _, _, _, _, value, _} ->
      {name, to_string(value)}
    end)
  end

  defp transform({:xmlText, _parents, _pos, _language, value, :text}), do: to_string(value)

  defp transform([
         {
           :xmlAttribute,
           _name,
           _expanded_name,
           _nsinfo,
           _namespace,
           _parents,
           _pos,
           _language,
           value,
           _normalized
         }
       ]),
       do: to_string(value)

  defp transform(source, from_type)
  defp transform([], _), do: nil
  defp transform(source, :element), do: Enum.map(source, &transform/1)
  defp transform(source, :text), do: Enum.map_join(source, ", ", &transform/1)
end
