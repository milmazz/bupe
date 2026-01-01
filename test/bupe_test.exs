defmodule BUPETest do
  use BUPETest.Case, async: true
  doctest BUPE
  doctest BUPE.Item

  describe "parse/1" do
    defp container_xml(rootfile) do
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
        <rootfiles>
          <rootfile full-path="#{rootfile}" media-type="application/oebps-package+xml"/>
        </rootfiles>
      </container>
      """
    end

    defp opf_with_assets do
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <package xmlns="http://www.idpf.org/2007/opf" unique-identifier="bookid" version="3.0" xml:lang="en">
        <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:identifier id="bookid">urn:uuid:123</dc:identifier>
          <dc:title>Sample</dc:title>
          <dc:language>en</dc:language>
          <meta property="dcterms:modified">2015-01-23T23:50:07Z</meta>
        </metadata>
        <manifest>
          <item id="p1" href="content/page.xhtml" media-type="application/xhtml+xml"/>
          <item id="css" href="content/style.css" media-type="text/css"/>
          <item id="js" href="content/app.js" media-type="text/javascript"/>
          <item id="img" href="content/image.png" media-type="image/png"/>
        </manifest>
        <spine>
          <itemref idref="p1"/>
        </spine>
      </package>
      """
    end

    test "parser should detect that file does not exists" do
      file_path = File.cwd!() |> Path.join(BUPE.UUID.uuid4() <> ".epub")
      msg = "file #{file_path} does not exists"

      assert_raise ArgumentError, msg, fn ->
        BUPE.parse(file_path)
      end
    end

    @tag :tmp_dir
    test "parser should detect invalid extensions", %{tmp_dir: tmp_dir} do
      file_path = tmp_dir |> Path.join(BUPE.UUID.uuid4() <> ".xhtml")
      File.touch!(file_path)
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

    @tag :tmp_dir
    test "parser should raise when the container file is missing", %{tmp_dir: tmp_dir} do
      path =
        tmp_dir
        |> Path.join("missing_container.epub")
        |> build_epub()

      assert_raise RuntimeError, "container file is missing", fn ->
        BUPE.parse(path)
      end
    end

    @tag :tmp_dir
    test "parser should raise when container has no rootfile", %{tmp_dir: tmp_dir} do
      container = """
      <?xml version="1.0" encoding="UTF-8"?>
      <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
        <rootfiles/>
      </container>
      """

      path =
        tmp_dir
        |> Path.join("no_rootfile.epub")
        |> build_epub([
          {"META-INF/container.xml", container}
        ])

      assert_raise RuntimeError, "could not find rootfile in META-INF/container.xml", fn ->
        BUPE.parse(path)
      end
    end

    @tag :tmp_dir
    test "parser should raise when rootfile cannot be parsed", %{tmp_dir: tmp_dir} do
      path =
        tmp_dir
        |> Path.join("invalid_rootfile.epub")
        |> build_epub([
          {"META-INF/container.xml", container_xml("OEBPS/content.opf")},
          {"OEBPS/content.opf", "<package><metadata></metadata>"}
        ])

      assert_raise RuntimeError, "could not parse the rootfile OEBPS/content.opf", fn ->
        BUPE.parse(path)
      end
    end

    @tag :tmp_dir
    test "parse files direct under the root directory", %{tmp_dir: tmp_dir} do
      package = """
      <?xml version="1.0" encoding="UTF-8"?>
      <package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="q">
        <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title id="title">Minimal EPUB 2.0</dc:title>
          <dc:language>en</dc:language>
          <dc:identifier id="q">NOID</dc:identifier>
        </metadata>
        <manifest>
          <item id="content_001"  href="content_001.xhtml" media-type="application/xhtml+xml"/>
          <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml" />
        </manifest>
        <spine toc="ncx">
          <itemref idref="content_001" />
        </spine>
      </package>
      """

      content = """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
        <head>
          <title>Minimal EPUB</title>
        </head>
        <body>
          <h1>Loomings</h1>
          <p>Call me Ishmael.</p>
        </body>
      </html>
      """

      toc = """
      <?xml version="1.0" encoding="UTF-8"?>
      <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
        <head>
          <meta name="dtb:depth" content="1"/>
        </head>
          <docTitle>
            <text>Minimal EPUB 2.0</text>
          </docTitle>
        <navMap>
          <navPoint id="np-1" playOrder="1">
            <navLabel>
              <text>Loomings</text>
            </navLabel>
            <content src="content_001.xhtml"/>
          </navPoint>
        </navMap>
      </ncx>
      """

      file_path =
        tmp_dir
        |> Path.join("ocf-minimal-valid.epub")
        |> build_epub([
          {"META-INF/container.xml", container_xml("package.opf")},
          {"package.opf", package},
          {"content_001.xhtml", content},
          {"toc.ncx", toc}
        ])

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
    test "parse assets from a rootfile in a subdirectory", %{tmp_dir: tmp_dir} do
      path =
        tmp_dir
        |> Path.join("subdir_assets.epub")
        |> build_epub([
          {"META-INF/container.xml", container_xml("OEBPS/content.opf")},
          {"OEBPS/content.opf", opf_with_assets()},
          {"OEBPS/content/page.xhtml", "<html><head><title>Page</title></head></html>"},
          {"OEBPS/content/style.css", "body { color: #000; }"},
          {"OEBPS/content/app.js", "console.log('ok');"},
          {"OEBPS/content/image.png", "PNGDATA"}
        ])

      assert %{pages: [page], styles: [style], scripts: [script], images: [image]} =
               BUPE.parse(path)

      assert page.href == "content/page.xhtml"
      assert page.content =~ "<title>Page</title>"

      assert style.href == "content/style.css"
      assert style.content =~ "body { color: #000; }"

      assert script.href == "content/app.js"
      assert script.content =~ "console.log('ok');"

      assert image.href == "content/image.png"
      assert image.content == "PNGDATA"
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
