defmodule BUPE.ItemTest do
  use ExUnit.Case, async: true

  alias BUPE.Item

  test "normalize/1 builds an item from a binary path with defaults" do
    item = Item.normalize("book/bacon.xhtml")

    assert %Item{href: "book/bacon.xhtml"} = item
    assert item.description == "bacon"
    assert item.media_type == "application/xhtml+xml"
    assert "i-" <> _uuid = item.id
  end

  test "normalize/1 keeps explicitly provided fields" do
    item =
      Item.normalize(%Item{
        id: "logo",
        href: "images/logo.png",
        description: "Logo",
        media_type: "image/custom"
      })

    assert item.id == "logo"
    assert item.description == "Logo"
    assert item.media_type == "image/custom"
  end

  test "normalize/1 infers the media type from the href" do
    assert Item.normalize(%Item{href: "images/logo.png"}).media_type == "image/png"
  end
end
