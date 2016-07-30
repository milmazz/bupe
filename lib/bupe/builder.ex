defmodule BUPE.Builder do
  @moduledoc ~S"""
  Elixir EPUB generator

  ## Example

  ```elixir
  config = %BUPE.Config{
    title: "Sample",
    language: "en",
    creator: "John Doe",
    publisher: "Sample",
    date: "2016-06-23T06:00:00Z",
    unique_identifier: "EXAMPLE",
    identifier: "http://example.com/book/jdoe/1",
    files: ["bacon.xhtml", "egg.xhtml", "ham.xhtml"],
    nav: [
      %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.xhtml"},
      %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.xhtml"},
      %{id: "ode-to-egg", label: "1. Ode to Egg", content: "egg.xhtml"}
    ]
  })

  BUPE.Builder.save(epub, "example.epub")
  ```

  """
  alias BUPE.Builder.Templates

  @doc """
  Generates an EPUB v3 document
  """
  @spec save(BUPE.Config.t, Path.t) :: String.t
  def save(config, output) do
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

    epub_file
  end

  defp generate_tmp_dir(config) do
    tmp_dir =
      (Keyword.get(config.extras, :tmp_dir) || System.tmp_dir())
      |> Path.join(".bupe/#{uuid4()}")

    if File.exists?(tmp_dir) do
      File.rm_rf!(tmp_dir)
    end

    tmp_dir
  end

  defp generate_mimetype(output) do
    content = "application/epub+zip"
    File.write("#{output}/mimetype", content)
  end

  # Package definition builder.
  #
  # According to the EPUB specification, the *Package Document* carries
  # bibliographic and structural metadata about an EPUB Publication, and is thus
  # the primary source of information about how to process and display it.
  #
  # The `package` element is the root container of the Package Document and
  # encapsulates Publication metadata and resource information.
  defp generate_package(config, output) do
    content = Templates.content_template(config)
    File.write!("#{output}/OEBPS/content.opf", content)
  end

  # Navigation Center eXtended definition
  #
  # Keep in mind that the EPUB Navigation Document defined in
  # `BUPE.Builder.Nav` supersedes this definition. According to the EPUB
  # specification:
  #
  # > EPUB 3 Publications may include an NCX (as defined in OPF 2.0.1) for EPUB
  # > 2 Reading System forwards compatibility purposes, but EPUB 3 Reading
  # > Systems must ignore the NCX.
  defp generate_ncx(config, output) do
    content = Templates.ncx_template(config)
    File.write!("#{output}/OEBPS/toc.ncx", content)
  end

  # Navigation Document Definition
  #
  # The TOC nav element defines the primary navigation hierarchy of the document.
  # It conceptually corresponds to a table of contents in a printed work.
  #
  # See [EPUB Navigation Document Definition][nav] for more information.
  #
  # [nav]: http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def
  defp generate_nav(config, output) do
    content = Templates.nav_template(config)
    File.write!("#{output}/OEBPS/nav.xhtml", content)
  end

  # Cover page definition for the EPUB document
  defp generate_title(config, output) do
    content = Templates.title_template(config)
    File.write!("#{output}/OEBPS/title.xhtml", content)
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
                                  compress: ['.css', '.html', '.xhtml', '.ncx',
                                             '.opf', '.jpg', '.png', '.xml'])
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
