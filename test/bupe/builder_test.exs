defmodule BUPE.BuilderTest do
  use BUPETest.Case, async: true

  defp unzip(binary) do
    {:ok, file_bin_list} = :zip.unzip(binary, [:memory])
    file_bin_list
  end

  @tag :tmp_dir
  test "build EPUB v2.0 document", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "v20.epub")

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
             name == ~c"OEBPS/nav.xhtml"
           end)
  end

  @tag :tmp_dir
  test "do not include cover page", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "sample.epub")

    {:ok, {_name, epub}} =
      config
      |> Map.put(:cover, false)
      |> BUPE.build(output, [:memory])

    # Extract EPUB content
    content = unzip(epub)

    # cover page should not be listed in the OPF
    {_, opf_template} =
      Enum.find(content, fn {name, _binary} ->
        name == ~c"OEBPS/content.opf"
      end)

    refute opf_template =~
             ~r{<item id="cover" href="title.xhtml" media-type="application/xhtml+xml" />}

    # the spine must not reference a manifest item that does not exist
    refute opf_template =~ ~s(<itemref idref="cover")

    refute Enum.find(content, fn {name, _binary} ->
             name == ~c"OEBPS/title.xhtml"
           end)
  end

  test "should raise exception for invalid extension in EPUB v2" do
    config = config()
    msg = "invalid file extension for HTML file, expected '.html', '.htm' or '.xhtml'"

    config =
      config
      |> Map.put(:pages, [%BUPE.Item{href: "page.png"}])
      |> Map.put(:version, "2.0")

    assert_raise BUPE.InvalidExtensionName, msg, fn ->
      BUPE.build(config, "sample.epub", [:memory])
    end
  end

  test "should raise exception for invalid extension in EPUB v3" do
    config = config()
    msg = "XHTML Content Document file names should have the extension '.xhtml'."

    config = Map.put(config, :pages, [%BUPE.Item{href: "page.png"}])

    assert_raise BUPE.InvalidExtensionName, msg, fn ->
      BUPE.build(config, "sample.epub", [:memory])
    end
  end

  test "raises exception for invalid dates" do
    config = config()
    msg = "date is invalid"

    for invalid_date_format <- [DateTime.utc_now(), "2015-01-23T23:50:07,123+02:30"] do
      config = Map.put(config, :modified, invalid_date_format)

      assert_raise BUPE.InvalidDate, msg, fn ->
        BUPE.build(config, "sample.epub", [:memory])
      end
    end

    assert {:ok, _} =
             config
             |> Map.put(:modified, _valid_datetime = "2015-01-23T23:50:07Z")
             |> BUPE.build("sample.epub", [:memory])
  end

  test "raises exception for invalid language tags" do
    config = config()

    for invalid_language <- ["en_US", "wubble", "en-en", "", nil] do
      config = Map.put(config, :language, invalid_language)

      assert_raise BUPE.InvalidLanguage, fn ->
        BUPE.build(config, "sample.epub", [:memory])
      end
    end

    assert_raise BUPE.InvalidLanguage, ~r/'en_us' is not registered/, fn ->
      config
      |> Map.put(:language, "en_US")
      |> BUPE.build("sample.epub", [:memory])
    end
  end

  @tag :tmp_dir
  test "accepts deprecated language tags and advisory issues", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "sample.epub")

    # "art-lojban" is deprecated and "gsw-Latn" carries a redundant default
    # script; both are well-formed, so reading systems accept them.
    for language <- ["art-lojban", "gsw-Latn", "en-GB"] do
      assert {:ok, _} =
               config
               |> Map.put(:language, language)
               |> BUPE.build(output, [:memory])
    end
  end

  @tag :tmp_dir
  test "should allow to build the EPUB in memory", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "v30.epub")

    {:ok, {filename, binary}} = BUPE.Builder.run(config, output, [:memory])

    assert is_binary(filename)
    File.write!(filename, binary)

    epub_info = BUPE.parse(binary)
    assert epub_info.version == "3.0"
  end

  @tag :tmp_dir
  test "returns the output path as a string", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "v30.epub")

    assert {:ok, path} = BUPE.build(config, output)
    assert path == output
    assert File.exists?(path)
  end

  @tag :tmp_dir
  test "includes the cover image media type in the package document", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "v30.epub")

    {:ok, {_name, epub}} =
      config
      |> Map.put(:logo, fixtures_dir("logo.png"))
      |> BUPE.build(output, [:memory])

    {_, opf} =
      epub
      |> unzip()
      |> Enum.find(fn {name, _binary} ->
        name == ~c"OEBPS/content.opf"
      end)

    assert opf =~
             ~s(<item id="cover-image" href="content/logo.png" media-type="image/png" properties="cover-image" />)
  end

  @tag :tmp_dir
  test "marks the cover image for EPUB 2 reading systems", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "v20.epub")

    {:ok, {_name, epub}} =
      config
      |> Map.put(:version, "2.0")
      |> Map.put(:logo, fixtures_dir("logo.png"))
      |> BUPE.build(output, [:memory])

    {_, opf} =
      epub
      |> unzip()
      |> Enum.find(fn {name, _binary} ->
        name == ~c"OEBPS/content.opf"
      end)

    # EPUB 2 identifies the cover through a meta element, and the
    # `properties` attribute does not exist in OPF 2.0
    assert opf =~ ~s(<meta name="cover" content="cover-image" />)

    assert opf =~
             ~s(<item id="cover-image" href="content/logo.png" media-type="image/png" />)
  end

  @tag :tmp_dir
  test "bundles the logo into the archive", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "v30.epub")
    logo = fixtures_dir("logo.png")

    {:ok, {_name, epub}} =
      config
      |> Map.put(:logo, logo)
      |> BUPE.build(output, [:memory])

    content = unzip(epub)

    assert {_, binary} =
             Enum.find(content, fn {name, _binary} ->
               name == ~c"OEBPS/content/logo.png"
             end)

    assert binary == File.read!(logo)

    {_, title_page} =
      Enum.find(content, fn {name, _binary} ->
        name == ~c"OEBPS/title.xhtml"
      end)

    assert title_page =~ ~s(src="content/logo.png")
  end

  @tag :tmp_dir
  test "does not duplicate the logo when it is also listed in images", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "v30.epub")
    logo = fixtures_dir("logo.png")

    {:ok, {_name, epub}} =
      config
      |> Map.put(:logo, logo)
      |> Map.put(:images, [logo])
      |> BUPE.build(output, [:memory])

    content = unzip(epub)

    assert Enum.count(content, fn {name, _binary} ->
             name == ~c"OEBPS/content/logo.png"
           end) == 1

    {_, opf} =
      Enum.find(content, fn {name, _binary} ->
        name == ~c"OEBPS/content.opf"
      end)

    assert opf =~ ~s(id="cover-image" href="content/logo.png")

    manifest_entries = opf |> String.split(~s(href="content/logo.png")) |> length()
    assert manifest_entries == 2
  end
end
