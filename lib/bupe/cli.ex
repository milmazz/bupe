defmodule BUPE.CLI do
  @moduledoc """
  CLI interface for BUPE.
  """

  @aliases [
    h: :help,
    l: :logo,
    o: :output,
    p: :page,
    v: :version
  ]

  @switches [
    help: :boolean,
    language: :string,
    logo: :string,
    output: :string,
    page: :keep,
    version: :boolean
  ]

  def main(args, builder \\ &BUPE.Builder.run/3) do
    {opts, args, _invalid} = OptionParser.parse(args, aliases: @aliases, switches: @switches)

    cond do
      Keyword.has_key?(opts, :version) ->
        print_version()

      Keyword.has_key?(opts, :help) ->
        print_usage()

      true ->
        generate(args, opts, builder)
    end
  end

  defp generate([], _, _) do
    IO.puts("Too few arguments.\n")
    print_usage()
    exit({:shutdown, 1})
  end

  defp generate([title], opts, builder) do
    opts =
      opts
      |> Keyword.put(:title, title)
      |> parse_pages()

    name = parse_output(opts, title)

    with {:ok, path} <- BUPE.Config |> struct(opts) |> builder.(name, []) do
      IO.puts("EPUB successfully generated:")
      path |> Path.relative_to_cwd() |> IO.puts()
    end
  end

  def parse_pages(opts) do
    case Keyword.get_values(opts, :page) do
      [] ->
        IO.puts("At least one page is required\n")
        print_usage()
        exit({:shutdown, 1})

      pages ->
        opts
        |> Keyword.delete(:page)
        |> Keyword.put(:pages, pages)
    end
  end

  def parse_output(opts, title) do
    Keyword.get_lazy(opts, :output, fn ->
      title
      |> String.downcase()
      |> String.replace(" ", "_")
      |> Kernel.<>(".epub")
    end)
  end

  defp print_version do
    IO.puts("BUPE v#{BUPE.version()}")
  end

  defp print_usage do
    IO.puts(~S"""
    Usage:
      bupe EPUB_TITLE [OPTIONS]

    Examples:
      bupe "Ode to Food" -p egg.xhtml -p bacon.xhtml

    Options:
      EPUB_TITLE      EPUB title
      -p, --page      Path to a page (e.g. XHTML) file that will be copied
                      to the EPUB file. May be given multiple times
      --language      Identify the primary language of the EPUB document, its
                      value must be a valid [BCP 47](https://tools.ietf.org/html/bcp47)
                      language tag, default: "en"
      -l, --logo      Path to the image logo of the EPUB document
      -v, --version   Print BUPE version
      -o, --output    Path to output EPUB document.
      -h, --help      Print this usage

    """)
  end
end
