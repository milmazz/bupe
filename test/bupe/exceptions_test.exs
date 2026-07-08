defmodule BUPE.ExceptionsTest do
  use ExUnit.Case, async: true

  test "BUPE.InvalidDate has a default message" do
    assert_raise BUPE.InvalidDate, "date is invalid", fn ->
      raise BUPE.InvalidDate
    end
  end

  test "BUPE.InvalidLanguage has a default message" do
    assert_raise BUPE.InvalidLanguage, "Language is invalid", fn ->
      raise BUPE.InvalidLanguage
    end
  end

  test "BUPE.InvalidVersion has a default message" do
    assert_raise BUPE.InvalidVersion, "invalid EPUB version, expected '2.0' or '3.0'", fn ->
      raise BUPE.InvalidVersion
    end
  end

  test "BUPE.InvalidExtensionName has a default message" do
    assert_raise BUPE.InvalidExtensionName, "invalid file extension name", fn ->
      raise BUPE.InvalidExtensionName
    end
  end
end
