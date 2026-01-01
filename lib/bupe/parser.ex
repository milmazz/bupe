defmodule BUPE.Parser do
  @moduledoc false

  alias BUPE.Config

  def run(<<0x04034B50::little-size(32), _::binary>> = epub), do: parse(epub)

  @spec run(Path.t()) :: Config.t() | no_return
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
         {:ok, config} <- parse_root_file(epub, root_file) do
      item_contents = ~w(pages images styles scripts toc)a

      content =
        Map.new(
          item_contents,
          &{&1, extract_item_content(epub, root_file, Map.get(config, &1) || [])}
        )

      struct(config, content)
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

    Enum.map(items, fn %{href: href} = item ->
      item = Map.put(item, :content, Map.get(content, href, ""))
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
    case extract_files(epub, ["mimetype"]) do
      [] ->
        raise "mimetype file is missing"

      [{~c"mimetype", "application/epub+zip"}] ->
        :ok

      _ ->
        raise "invalid mimetype, must be 'application/epub+zip'"
    end
  end

  def find_rootfile(epub) do
    container = ~c"META-INF/container.xml"

    case extract_files(epub, [container]) do
      [] ->
        raise "container file is missing"

      [{^container, content}] ->
        case Saxy.parse_string(content, BUPE.Parser.ContainerHandler, nil) do
          {:ok, path} when is_binary(path) -> {:ok, path}
          _ -> raise "could not find rootfile in #{container}"
        end
    end
  end

  defp parse_root_file(epub, root_file) do
    file = String.to_charlist(root_file)
    [{^file, content}] = extract_files(epub, [file])

    case Saxy.parse_string(content, BUPE.Parser.RootFileHandler, %Config{title: nil, pages: nil}) do
      {:ok, config} -> {:ok, config}
      _ -> raise "could not parse the rootfile #{root_file}"
    end
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
end
