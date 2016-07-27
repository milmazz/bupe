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
  @spec parse(Path.t) :: String.t | no_return
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

    # TODO: Format content
    content
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
end
