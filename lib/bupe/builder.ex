defmodule BUPE.Builder do
  @moduledoc """
  Elixir EPUB generator

  epub = BUPE.Builder.new(%BUPE.Config{
    title: "Sample",
    lang: "en",
    creator: "John Doe",
    publisher: "Sample",
    date: "2016-06-23",
    unique_identifier: "http://example.com/book/jdoe/1",
    scheme: "URL",
    uid: "http://example.com/book/jdoe/1",
    files: ["bacon.xhtml", "egg.xhtml", "ham.xhtml"],
    nav: [
      %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.xhtml"},
      %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.xhtml"},
      %{id: "ode-to-egg", label: "1. Ode to Egg", content: "egg.xhtml"}
    ]
  })

  BUPE.Builder.save(epub, "example.epub")
  """
  alias BUPE.Builder

  @spec save(%BUPE.Config{}, Path.t, Keyword.t) :: String.t
  def save(config, output, opts \\ []) do
    start_time = System.monotonic_time()
    output = Path.expand(output)

    # TODO: Ask the user if they want to replace the existing file.
    if File.exists?(output) do
      File.rm!(output)
    end

    tmp_dir = generate_tmp_dir(config)

    File.mkdir_p!(Path.join(tmp_dir, "OEBPS"))

    assets() |> assets_path() |> generate_assets(tmp_dir)

    generate_mimetype(tmp_dir)
    generate_package(config, tmp_dir)
    generate_ncx(config, tmp_dir)
    generate_nav(config, tmp_dir)
    generate_title(config, tmp_dir)
    generate_content(config, tmp_dir)

    {:ok, epub_file} = generate_epub(tmp_dir, output)

    File.rm_rf!(tmp_dir)

    if opts[:verbose] do
      end_time = System.monotonic_time()
      diff = System.convert_time_unit(end_time - start_time, :native, :milliseconds)
      IO.puts "EPUB file #{output} created in #{diff} milliseconds"
    end

    epub_file
  end

  defp generate_tmp_dir(config) do
    tmp_dir = Path.join(config[:extras][:tmp_dir] || System.tmp_dir(), ".bupe/#{uuid4()}")

    if File.exists?(tmp_dir) do
      File.rm_rf!(tmp_dir)
    end

    tmp_dir
  end

  defp generate_mimetype(output) do
    content = "application/epub+zip"
    File.write("#{output}/mimetype", content)
  end

  defp generate_package(config, output) do
    config |> Builder.Package.save("#{output}/OEBPS/content.opf")
  end

  defp generate_ncx(config, output) do
    config |> Builder.NCX.save("#{output}/OEBPS/toc.ncx")
  end

  defp generate_nav(config, output) do
    config |> Builder.Nav.save("#{output}/OEBPS/nav.xhtml")
  end

  defp generate_title(config, output) do
    config |> Builder.Title.save("#{output}/OEBPS/title.xhtml")
  end

  defp generate_content(config, output) do
      output = Path.join(output, "OEBPS/content")
      File.mkdir! output
      copy_files(config.files, output)
  end

  defp generate_epub(input, output) do
    target_path = Path.expand(output) |> String.to_char_list()

    {:ok, zip_path} = :zip.create(target_path,
                                  files_to_add(input),
                                  compress: ['.css', '.html', '.xhtml', '.ncx', '.opf',
                                             '.jpg', '.png', '.xml'])
    {:ok, zip_path}
  end

  ## Helpers
  defp files_to_add(path) do
    File.cd! path, fn ->
      meta = Path.wildcard("META-INF/*")
      oebps = Path.wildcard("OEBPS/**/*")

      Enum.reduce meta ++ oebps ++ ["mimetype"], [], fn(f, acc) ->
        case File.read(f) do
          {:ok, bin} ->
            [{f |> String.to_char_list, bin}|acc]
          {:error, _} ->
            acc
        end
      end
    end
  end

  defp assets do
    [
      {"css/*.css", "OEBPS/css"},
      {"assets/*.xml", "META-INF"}
    ]
  end

  defp assets_path(patterns) do
    Enum.into(patterns, [], fn {pattern, dir} ->
      {Application.app_dir(:bupe, "priv/bupe/builder/templates/#{pattern}"), dir}
    end)
  end

  defp generate_assets(source, output) do
    Enum.each source, fn({pattern, dir}) ->
      output = "#{output}/#{dir}"
      File.mkdir output

      copy_files(Path.wildcard(pattern), output)
    end
  end

  defp copy_files(files, output) do
    Enum.map files, fn(file) ->
      base = Path.basename(file)
      File.copy file, "#{output}/#{base}"
    end
  end

  # Helper to generate an UUID, in particular version 4 as specified in
  # [RFC 4122](https://tools.ietf.org/html/rfc4122.html)
  defp uuid4 do
    <<u0::48, _::4, u1::12, _::2, u2::62>> = :crypto.strong_rand_bytes(16)
    bin = <<u0::48, 4::4, u1::12, 2::2, u2::62>>
    <<u0::32, u1::16, u2::16, u3::16, u4::48>> = bin

    Enum.map_join([<<u0::32>>, <<u1::16>>, <<u2::16>>, <<u3::16>>, <<u4::48>>], <<45>>,
                  &(Base.encode16(&1, case: :lower)))
  end
end
