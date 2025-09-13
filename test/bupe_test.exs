defmodule BUPETest do
  use BUPETest.Case, async: true
  doctest BUPE
  doctest BUPE.Item

  describe "parse/1" do
    test "parser should detect that file does not exists" do
      file_path = fixtures_dir("404.epub")
      msg = "file #{file_path} does not exists"

      assert_raise ArgumentError, msg, fn ->
        BUPE.parse(file_path)
      end
    end

    test "parser should detect invalid extensions" do
      file_path = fixtures_dir("30/bacon.xhtml")
      msg = "file #{file_path} does not have an '.epub' extension"

      assert_raise ArgumentError, msg, fn ->
        BUPE.parse(file_path)
      end
    end

    test "parser should report invalid EPUB mimetype" do
      msg = "invalid mimetype, must be 'application/epub+zip'"

      assert_raise RuntimeError, msg, fn ->
        "invalid_mimetype.epub" |> fixtures_dir() |> BUPE.parse()
      end
    end

    test "parse files direct under the root directory" do
      file_path = fixtures_dir("ocf-minimal-valid.epub")

      assert %BUPE.Config{} = result = BUPE.parse(file_path)

      assert result.version == "2.0"
      assert result.title == "Minimal EPUB 2.0"
      assert result.identifier == "NOID"

      assert result.nav == [%{idref: "content_001"}]
      [page] = result.pages
      assert page.href == "content_001.xhtml"
      assert page.id == "content_001"
      assert page.media_type == "application/xhtml+xml"
      assert page.content =~ "<title>Minimal EPUB</title>"
    end

    @tag :tmp_dir
    test "parse toc of epub version 3.0", %{tmp_dir: tmp_dir} do
      config = config()

      output = Path.join(tmp_dir, "sample.epub")
      {:ok, {_name, epub}} = BUPE.build(config, output, [:memory])

      epub_info = BUPE.parse(epub)

      [toc] = epub_info.toc
      assert toc.id == "nav"
      assert toc.href == "nav.xhtml"
      assert toc.media_type == "application/xhtml+xml"
      assert toc.content =~ "Table of contents"
    end

    @tag :tmp_dir
    test "parse toc of epub version 2.0", %{tmp_dir: tmp_dir} do
      config = config()
      config = Map.put(config, :version, "2.0")

      output = Path.join(tmp_dir, "sample.epub")
      {:ok, {_name, epub}} = BUPE.build(config, output, [:memory])

      epub_info = BUPE.parse(epub)

      [toc] = epub_info.toc
      assert toc.id == "ncx"
      assert toc.href == "toc.ncx"
      assert toc.media_type == "application/x-dtbncx+xml"
      assert toc.content =~ "Book cover"
    end
  end

  describe "build/3" do
    @tag :tmp_dir
    test "build epub document version 3", %{tmp_dir: tmp_dir} do
      config = config()

      output = Path.join(tmp_dir, "sample.epub")
      {:ok, {_name, epub}} = BUPE.build(config, output, [:memory])

      epub_info = BUPE.parse(epub)

      assert epub_info.title == config.title
      assert epub_info.creator == config.creator
      assert epub_info.version == config.version
    end

    test "builder should report invalid EPUB version" do
      config = config()
      config = Map.put(config, :version, "4.0")
      msg = "invalid EPUB version, expected '2.0' or '3.0'"

      assert_raise BUPE.InvalidVersion, msg, fn ->
        BUPE.build(config, "sample.epub")
      end
    end
  end
end
