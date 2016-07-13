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
    files: ["path/bacon.html", "path/egg.html", "path/ham.html"],
    nav => [
      [id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.html"],
      [id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.html"],
      [id: "ode-to-egg", label: "1. Ode to Egg", content: "egg.html"]
    ]
  })

  BUPE.Builder.save(epub, "example.epub")
  """
  alias BUPE.Builder

  def save(config, file) do
    # FIXME: This should be a temp directory
    output = Path.expand(config.output)

    # TODO: Is this necessary?
    if File.exists?(output) do
      File.rm_rf!(output)
    end

    File.mkdir_p!("#{output}/OEBPS/")

    assets() |> templates_path() |> generate_assets(output)

    generate_mimetype(output)
    generate_content(output, config)
    generate_toc(output, config)
    generate_nav(output, config)
    generate_title(output, config)

    {:ok, epub_file} = generate_epub(output, file)

    # TODO: Delete temp directory
    epub_file
  end

  defp generate_mimetype(output) do
    content = "application/epub+zip"
    File.write("#{output}/mimetype", content)
  end

  defp generate_content(config, output) do
    config |> Builder.Package.save("#{output}/OEBPS/content.opf")
  end

  defp generate_toc(config, output) do
    config |> Builder.TOC.save("#{output}/OEBPS/toc.ncx")
  end

  defp generate_nav(config, output) do
    config |> Builder.Nav.save("#{output}/OEBPS/nav.html")
  end

  defp generate_title(config, output) do
    config |> Builder.Title.save("#{output}/OEBPS/title.html")
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

  defp templates_path(patterns) do
    Enum.into(patterns, [], fn {pattern, dir} ->
      {Path.expand("builder/templates/#{pattern}", __DIR__), dir}
    end)
  end

  defp generate_assets(source, output) do
    Enum.each source, fn({pattern, dir}) ->
      output = "#{output}/#{dir}"
      File.mkdir output

      Enum.map Path.wildcard(pattern), fn(file) ->
        base = Path.basename(file)
        File.copy file, "#{output}/#{base}"
      end
    end
  end
end
