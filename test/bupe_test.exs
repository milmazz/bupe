defmodule BUPETest do
  use BUPETest.Case, async: true
  doctest BUPE

  test "file does not exists" do
    file_path = fixtures_dir("404.epub")
    msg = "file #{file_path} does not exists"

    assert_raise ArgumentError, msg, fn ->
      BUPE.parse(file_path)
    end
  end

  test "invalid extension" do
    file_path = fixtures_dir("bacon.xhtml")
    msg = "file #{file_path} does not have an '.epub' extension"

    assert_raise ArgumentError, msg, fn ->
      BUPE.parse(file_path)
    end
  end

  test "invalid mimetype" do
    msg = "invalid mimetype, must be 'application/epub+zip'"

    assert_raise RuntimeError, msg, fn ->
      fixtures_dir("invalid_mimetype.epub")
      |> BUPE.parse()
    end
  end

  test "build epub document version 3" do
    config = config(%{})

    output = Path.join(tmp_dir(), "sample.epub")
    BUPE.build(config, output)

    epub_info = BUPE.parse(output)

    assert File.exists?(output)
    assert epub_info.title == config.title
    assert epub_info.creator == config.creator
    assert epub_info.version == config.version
  end
end
