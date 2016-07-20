defmodule BUPE.Builder.TitleTest do
  use BUPETest.Case, async: true

  test "save title template" do
    config = config(%{})
    output = "#{tmp_dir()}/title.xhtml"

    BUPE.Builder.Title.save(config, output)

    content = File.read!(output)

    assert content =~ ~r{<h1>Sample</h1>}
    assert content =~ ~r{<title>Sample</title>}
  end
end
