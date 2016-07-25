defmodule BUPE.Parser.ParserTest do
  use BUPETest.Case, async: true

  alias BUPE.Parser

  test "file does not exists" do
    file_path = fixtures_dir("404.epub")
    msg = "file #{file_path} does not exists"

    assert_raise ArgumentError, msg, fn ->
      Parser.parse(file_path)
    end
  end

  test "invalid extension" do
    file_path = fixtures_dir("bacon.xhtml")
    msg = "file #{file_path} does not have an '.epub' extension"

    assert_raise ArgumentError, msg, fn ->
      Parser.parse(file_path)
    end
  end

  test "invalid mimetype" do
    msg = "invalid mimetype, must be 'application/epub+zip'"

    assert_raise RuntimeError, msg, fn ->
      fixtures_dir("invalid_mimetype.epub")
      |> Parser.parse()
    end
  end

  @tag :skip
  test "epub document version 3" do
  end
end
