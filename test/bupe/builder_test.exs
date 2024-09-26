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

  @tag :tmp_dir
  test "should allow to build the EPUB in memory", %{tmp_dir: tmp_dir} do
    config = config()
    output = Path.join(tmp_dir, "v30.epub")

    {:ok, {filename, binary}} = BUPE.Builder.run(config, output, [:memory])

    File.write!(filename, binary)

    epub_info = BUPE.parse(binary)
    assert epub_info.version == "3.0"
  end
end
