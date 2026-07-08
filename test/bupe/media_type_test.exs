defmodule BUPE.MediaTypeTest do
  use ExUnit.Case, async: true

  alias BUPE.MediaType

  test "infers the media type from the file extension" do
    assert MediaType.from_path("book/bacon.xhtml") == "application/xhtml+xml"
    assert MediaType.from_path("book/intro.html") == "application/xhtml+xml"
    assert MediaType.from_path("styles/app.css") == "text/css"
    assert MediaType.from_path("scripts/app.js") == "text/javascript"
    assert MediaType.from_path("images/logo.png") == "image/png"
    assert MediaType.from_path("images/photo.jpg") == "image/jpeg"
    assert MediaType.from_path("audio/intro.mp3") == "audio/mpeg"
    assert MediaType.from_path("fonts/serif.ttf") == "application/vnd.ms-opentype"
  end

  test "ignores the extension case" do
    assert MediaType.from_path("images/PHOTO.JPG") == "image/jpeg"
  end

  test "returns nil for unknown extensions" do
    assert MediaType.from_path("README") == nil
    assert MediaType.from_path("archive.zip") == nil
  end
end
