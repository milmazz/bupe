defmodule BUPE.Parser do
  @moduledoc ~S"""
  An [EPUB 3][EPUB] conforming parser. This implementation should support also
  EPUB 2.

  ## Example

  ```iex
  BUPE.Parser.parse("sample.epub")
  #=> %BUPE.Config{
        title: "Sample",
        creator: "John Doe",
        unique_identifier: "EXAMPLE",
        files: ["bacon.xhtml", "ham.xhtml", "egg.xhtml"],
        nav: [
          %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.xhtml"},
          %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.xhtml"},
          %{id: "ode-to-egg", label: "3. Ode to Egg", content: "egg.xhtml"}
        ]
      }
  ```

  [EPUB]: http://www.idpf.org/epub3/latest/overview

  """

  @doc """
  EPUB v3 parser
  """
  @spec parse(Path.t) :: BUPE.Config.t | no_return
  def parse(epub_file) when is_binary(epub_file) do
    epub_file = Path.expand(epub_file)

    check_file(epub_file)
    check_extension(epub_file)
    check_mimetype(epub_file)
    find_rootfile(epub_file) |> extract_info(epub_file)
  end

  defp check_file(epub_file) do
    unless File.exists? epub_file do
      raise ArgumentError, "file #{epub_file} does not exists"
    end
  end

  defp check_extension(epub_file) do
    unless Path.extname(epub_file) |> String.downcase() == ".epub" do
      raise ArgumentError, "file #{epub_file} does not have an '.epub' extension"
    end
  end

  defp check_mimetype(epub_file) do
    unless extract_content(epub_file, ["mimetype"]) |> mimetype_valid? do
      raise "invalid mimetype, must be 'application/epub+zip'"
    end
  end

  defp mimetype_valid?([{'mimetype', "application/epub+zip"}]), do: true
  defp mimetype_valid?(_), do: false

  defp find_rootfile(epub_file) do
    container = 'META-INF/container.xml'
    [{^container, content}] = extract_content(epub_file, [container])
    captures =
      ~r/<rootfile\s.*full-path="(?<full_path>[^"]+)"\s/
      |> Regex.named_captures(content)

    unless captures do
      raise "could not find rootfile in META-INF/container.xml"
    end

    captures["full_path"]
  end

  defp extract_info(root_file, epub_file) do
    root_file = root_file |> String.to_char_list()
    [{^root_file, content}] = extract_content(epub_file, [root_file])

    {xml, _rest} = :xmerl_scan.string(String.to_char_list(content))

    %BUPE.Config{
      title: find_metadata(xml, "title"),
      language: find_language(xml),
      version: find_version(xml),
      identifier: find_metadata(xml, "identifier"),
      creator: find_metadata(xml, "creator"),
      contributor: find_metadata(xml, "contributor"),
      modified: find_modified(xml),
      date: find_metadata(xml, "date"),
      unique_identifier: find_unique_identifier(xml),
      source: find_metadata(xml, "source"),
      type: find_metadata(xml, "type"),
      description: find_metadata(xml, "description"),
      format: find_metadata(xml, "format"),
      coverage: find_metadata(xml, "coverage"),
      publisher: find_metadata(xml, "publisher"),
      relation: find_metadata(xml, "relation"),
      rights: find_metadata(xml, "rights"),
      subject: find_metadata(xml, "subject"),
      files: nil,
      nav: nil
    }
  end

  defp extract_content(epub_file, files) when is_list(files) do
    archive = epub_file |> String.to_char_list()
    file_list = Enum.into files, [], &(if is_list(&1), do: &1, else: String.to_char_list(&1))

    case :zip.extract(archive, [{:file_list, file_list}, :memory]) do
      {:ok, content} ->
        content
      {:error, reason} ->
        raise reason
    end
  end

  defp find_metadata(xml, meta) do
    xpath = "/package/metadata/dc:#{meta}/text()"

    xpath_string(xpath, xml) |> parse_xml_text()
  end

  defp xpath_string(xpath, xml) do
    :xmerl_xpath.string(xpath |> String.to_char_list(), xml)
  end

  defp find_modified(xml) do
    xpath_string("/package/metadata/meta[contains(@property, 'dcterms:modified')]/text()", xml)
    |> parse_xml_text()
  end

  defp find_version(xml) do
    xpath_string("/package/@version", xml) |> parse_xml_attribute()
  end

  defp find_language(xml) do
    find_metadata(xml, "language") || xpath_string("/package/@xml:lang", xml) |> parse_xml_attribute()
  end

  defp find_unique_identifier(xml) do
    xpath_string("/package/@unique-identifier", xml) |> parse_xml_attribute()
  end

  defp parse_xml_text([{:xmlText, _parents, _pos, _language, value, :text}]), do: to_string(value)
  defp parse_xml_text([]), do: nil

  defp parse_xml_attribute([{:xmlAttribute, _name, _expanded_name, _nsinfo, _namespace, _parents, _pos, _language, value, _normalized}]), do: to_string(value)
  defp parse_xml_attribute([]), do: nil
end
