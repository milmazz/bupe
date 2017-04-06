defmodule BUPE.BuilderTest do
  use BUPETest.Case, async: true

  defp unzip_content(output) do
    output |> String.to_charlist() |> :zip.unzip([cwd: tmp_dir()])
  end

  test "build EPUB v2.0 document" do
    config = config()
    output = Path.join(tmp_dir(), "v20.epub")

    config
    |> Map.put(:version, "2.0")
    |> BUPE.build(output)

    epub_info = BUPE.parse(output)
    assert epub_info.version == "2.0"

    # Extract EPUB content
    unzip_content(output)

    # NAV file is not supported in EPUB v2
    refute tmp_dir() |> Path.join("OEBPS/nav.xhtml") |> File.exists?()
  end

  test "do not include cover page" do
    config = config()
    output = Path.join(tmp_dir(), "sample.epub")

    config
    |> Map.put(:cover, false)
    |> BUPE.build(output)

    # Extract EPUB content
    unzip_content(output)

    # cover page should not be listed in the NCX file
    ncx_template = tmp_dir() |> Path.join("OEBPS/toc.ncx") |> File.read()
    refute ncx_template =~ ~r{<content src="title.xhtml" />}

    # cover page should not be listed in the OPF
    opf_template = tmp_dir() |> Path.join("OEBPS/content.opf") |> File.read()
    refute opf_template =~ ~r{<item id="cover" href="title.xhtml" media-type="application/xhtml+xml" />}

    refute tmp_dir() |> Path.join("OEBPS/title.xhtml") |> File.exists?()
  end
end
