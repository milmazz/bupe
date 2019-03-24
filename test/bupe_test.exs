defmodule BUPETest do
  use BUPETest.Case, async: true
  doctest BUPE

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
      fixtures_dir("invalid_mimetype.epub") |> BUPE.parse()
    end
  end

  test "build epub document version 3" do
    config = config()

    output = Path.join(tmp_dir(), "sample.epub")
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
