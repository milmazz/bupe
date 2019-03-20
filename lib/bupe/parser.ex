defmodule BUPE.Parser do
  @moduledoc ~S"""
  An [EPUB 3][EPUB] conforming parser. This implementation should support also
  EPUB 2.

  ## Example

  ```iex
  BUPE.Parser.parse("sample.epub")
  #=> %BUPE.Config{
        creator: "John Doe",
        nav: [
          %{idref: 'ode-to-bacon'},
          %{idref: 'ode-to-ham'},
          %{idref: 'ode-to-egg'}
        ],
        pages: [
          %{
            href: 'bacon.xhtml',
            id: 'ode-to-bacon',
            "media-type": 'application/xhtml+xml'
          },
          %{
            href: 'ham.xhtml',
            id: 'ode-to-ham',
            "media-type": 'application/xhtml+xml'
          },
          %{
            href: "egg.xhtml",
            id: 'ode-to-egg',
            "media-type": 'application/xhtml+xml'
          }
        ],
        styles: [
          %{href: 'stylesheet.css', id: 'styles', "media-type": 'text/css'}
        ],
        title: "Sample",
        unique_identifier: "EXAMPLE",
        version: "3.0"
      }
  ```

  [EPUB]: http://www.idpf.org/epub3/latest/overview

  """

  @doc """
  EPUB v3 parser
  """
  def run(<<0x04034B50::little-size(32), _::binary>> = epub) do
    parse(epub)
  end

  @spec run(Path.t()) :: BUPE.Config.t() | no_return
  def run(epub) when is_binary(epub) do
    epub
    |> Path.expand()
    |> String.to_charlist()
    |> check_file()
    |> check_extension()
    |> parse()
  end

  defp parse(epub) do
    epub
    |> check_mimetype()
    |> find_rootfile()
    |> scan_content()
    |> parse_xml(:metadata)
    |> parse_xml(:manifest)
    |> parse_xml(:navigation)
    |> parse_xml(:extras)
  end

  defp check_file(epub) do
    unless File.exists?(epub) do
      raise ArgumentError, "file #{epub} does not exists"
    end

    epub
  end

  defp check_extension(epub) do
    unless epub |> Path.extname() |> String.downcase() == ".epub" do
      raise ArgumentError, "file #{epub} does not have an '.epub' extension"
    end

    epub
  end

  defp check_mimetype(epub) do
    unless epub |> extract_files(["mimetype"]) |> mimetype_valid?() do
      raise "invalid mimetype, must be 'application/epub+zip'"
    end

    epub
  end

  defp mimetype_valid?([{'mimetype', "application/epub+zip"}]), do: true
  defp mimetype_valid?(_), do: false

  defp find_rootfile(epub) do
    container = 'META-INF/container.xml'
    [{^container, content}] = extract_files(epub, [container])
    captures = Regex.named_captures(~r/<rootfile\s.*full-path="(?<full_path>[^"]+)"\s/, content)

    unless captures do
      raise "could not find rootfile in #{container}"
    end

    {epub, captures["full_path"]}
  end

  defp scan_content({epub, root_file}) do
    root_file = String.to_charlist(root_file)
    [{^root_file, content}] = extract_files(epub, [root_file])

    {xml, _rest} = content |> :erlang.bitstring_to_list() |> :xmerl_scan.string()

    xml
  end

  defp parse_xml({xml, config}, :extras) do
    %{
      config
      | language: find_language(xml),
        version: find_xml(xml, filter: "/package/@version", type: :attribute),
        unique_identifier: find_xml(xml, filter: "/package/@unique-identifier", type: :attribute)
    }
  end

  defp parse_xml({xml, config}, :manifest) do
    {xml,
     %{
       config
       | images: find_manifest(xml, ["image/jpeg", "image/gif", "image/png", "image/svg+xml"]),
         scripts: find_manifest(xml, "application/javascript"),
         styles: find_manifest(xml, "text/css"),
         pages: find_manifest(xml, "application/xhtml+xml"),
         audio: find_manifest(xml, ["audio/mpeg", "audio/mp4"]),
         fonts:
           find_manifest(xml, ["application/font-sfnt", "application/font-woff", "font/woff2"])
     }}
  end

  defp parse_xml(xml, :metadata) do
    {xml,
     %BUPE.Config{
       title: find_metadata(xml, "title"),
       nav: nil,
       pages: nil,
       identifier: find_metadata(xml, "identifier"),
       creator: find_metadata(xml, "creator"),
       contributor: find_metadata(xml, "contributor"),
       modified: find_metadata_property(xml, "dcterms:modified"),
       date: find_metadata(xml, "date"),
       source: find_metadata(xml, "source") || find_metadata_property(xml, "dcterms:source"),
       type: find_metadata(xml, "type"),
       description: find_metadata(xml, "description"),
       format: find_metadata(xml, "format"),
       coverage: find_metadata(xml, "coverage"),
       publisher: find_metadata(xml, "publisher"),
       relation: find_metadata(xml, "relation"),
       rights: find_metadata(xml, "rights"),
       subject: find_metadata(xml, "subject")
     }}
  end

  defp parse_xml({xml, config}, :navigation) do
    {xml, %{config | nav: find_xml(xml, filter: "/package/spine/*", type: :element)}}
  end

  defp extract_files(archive, files) when is_list(files) do
    file_list = Enum.into(files, [], &if(is_list(&1), do: &1, else: String.to_charlist(&1)))

    case :zip.extract(archive, [{:file_list, file_list}, :memory]) do
      {:ok, content} ->
        content

      {:error, reason} ->
        raise reason
    end
  end

  defp find_metadata(xml, meta) do
    find_xml(xml, filter: "/package/metadata/dc:#{meta}/text()", type: :text)
  end

  defp find_metadata_property(xml, property) do
    find_xml(
      xml,
      filter: "/package/metadata/meta[contains(@property, '#{property}')]/text()",
      type: :text
    )
  end

  defp find_manifest(xml, media_types) when is_list(media_types) do
    filter =
      media_types
      |> Enum.map(fn type -> "@media-type='#{type}'" end)
      |> Enum.join(" or ")

    find_xml(xml, filter: "/package/manifest/item[#{filter}]", type: :element)
  end

  defp find_manifest(xml, media_type), do: find_manifest(xml, [media_type])

  defp find_xml(xml, filter: filter, type: :attribute),
    do: filter |> xpath_string(xml) |> transform()

  defp find_xml(xml, filter: filter, type: type),
    do: filter |> xpath_string(xml) |> transform(from: type)

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
    Enum.into(attributes, %{}, fn {:xmlAttribute, name, _, _, _, _, _, _, value, _} ->
      {name, value}
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

  defp transform([], _), do: nil
  defp transform(source, from: :element), do: Enum.map(source, &transform/1)
  defp transform(source, from: :text), do: source |> Enum.map(&transform/1) |> Enum.join(", ")
end
