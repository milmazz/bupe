defmodule BUPE.Builder.BuilderTest do
  use BUPETest.Case, async: true

  test "save epub doc" do
    config = config(%{})

    output = Path.join(tmp_dir(), "sample.epub")
    BUPE.Builder.save(config, output)

    assert File.exists?(output)
  end
end
