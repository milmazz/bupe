defmodule BUPE.Builder do
  @moduledoc """
  Elixir EPUB generator

  epub = BUPE.Builder.new(%BUPE.Config{
    title: "Sample",
    lang: "en",
    creator: "John Doe",
    publisher: "Sample",
    date: "2016-06-23",
    identifier: "http://example.com/book/jdoe/1",
    scheme: "URL",
    uid: "http://example.com/book/jdoe/1",
    files: ["bacon.html", "egg.html", "ham.html"],
    nav: [
      %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.html"},
      %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.html"},
      %{id: "ode-to-egg", label: "1. Ode to Egg", content: "egg.html"}
    ]
  })

  BUPE.Builder.save(epub, "example.epub")
  """
  alias BUPE.Builder

  def save(config, output) do
    output = Path.expand(output)

    # TODO: Ask the user if they want to replace the existing file.
    if File.exists?(output) do
      File.rm!(output)
    end

    # FIXME: Create a temp subdirectory
    tmp_dir = Path.join(config[:tmp_dir] || System.tmp_dir(), ".pube")

    if File.exists?(tmp_dir) do
      File.rm_rf!(tmp_dir)
    end

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

    epub_file
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
    config |> Builder.Nav.save("#{output}/OEBPS/nav.html")
  end

  defp generate_title(config, output) do
    config |> Builder.Title.save("#{output}/OEBPS/title.html")
  end

  defp generate_content(config, output) do
      output = Path.join(output, "content")
      File.mkdir! output
      copy_files(output, config.files)
  end

  defp generate_epub(input, output) do
    target_path = Path.expand(output) |> String.to_char_list()

    {:ok, zip_path} = :zip.create(target_path,
                                  files_to_add(input),
                                  compress: ['.css', '.html', '.ncx', '.opf',
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

      copy_files(output, Path.wildcard(pattern))
    end
  end

  defp copy_files(output, files) do
    Enum.map files, fn(file) ->
      base = Path.basename(file)
      File.copy file, "#{output}/#{base}"
    end
  end
end
