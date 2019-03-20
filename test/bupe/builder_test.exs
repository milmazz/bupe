defmodule BUPE.BuilderTest do
  use BUPETest.Case, async: true

  defp unzip(binary) do
    {:ok, file_bin_list} = :zip.unzip(binary, [:memory])
    file_bin_list
  end

  test "build EPUB v2.0 document" do
    config = config()
    output = Path.join(tmp_dir(), "v20.epub")

    {:ok, {_name, epub}} =
      config
      |> Map.put(:version, "2.0")
      |> BUPE.build(output, [:memory])

    epub_info = BUPE.parse(epub)
    assert epub_info.version == "2.0"

    # NAV file is not supported in EPUB v2
    refute epub
           |> unzip()
           |> Enum.find(fn {name, _binary} ->
             name == 'OEBPS/nav.xhtml'
           end)
  end

  test "do not include cover page" do
    config = config()
    output = Path.join(tmp_dir(), "sample.epub")

    {:ok, {_name, epub}} =
      config
      |> Map.put(:cover, false)
      |> BUPE.build(output, [:memory])

    # Extract EPUB content
    content = unzip(epub)

    # cover page should not be listed in the OPF
    {_, opf_template} =
      Enum.find(content, fn {name, _binary} ->
        name == 'OEBPS/content.opf'
      end)

    refute opf_template =~
             ~r{<item id="cover" href="title.xhtml" media-type="application/xhtml+xml" />}

    refute Enum.find(content, fn {name, _binary} ->
             name == 'OEBPS/title.xhtml'
           end)
  end

  test "should raise exception for invalid extension in EPUB v2" do
    config = config()
    msg = "invalid file extension for HTML file, expected '.html', '.htm' or '.xhtml'"

    config =
      config
      |> Map.put(:pages, [%{href: "page.png"}])
      |> Map.put(:version, "2.0")

    assert_raise BUPE.Config.InvalidExtensionName, msg, fn ->
      BUPE.build(config, "sample.epub", [:memory])
    end
  end

  test "should raise exception for invalid extension in EPUB v3" do
    config = config()
    msg = "XHTML Content Document file names should have the extension '.xhtml'."

    config = Map.put(config, :pages, [%{href: "page.png"}])

    assert_raise BUPE.Config.InvalidExtensionName, msg, fn ->
      BUPE.build(config, "sample.epub", [:memory])
    end
  end

  test "should allow to build the EPUB in memory" do
    config = config()
    output = Path.join(tmp_dir(), "v30.epub")

    {:ok, {filename, binary}} = BUPE.Builder.run(config, output, [:memory])

    File.write!(filename, binary)

    epub_info = BUPE.parse(binary)
    assert epub_info.version == "3.0"
  end
end
