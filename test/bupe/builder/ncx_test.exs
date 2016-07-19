defmodule BUPE.Builder.NCXTest do
  use BUPETest.Case, async: true

  test "save toc template" do
    config = config(%{})
    output = "#{tmp_dir()}/toc.html"

    BUPE.Builder.NCX.save(config, output)

    content = File.read!(output)

    assert content =~ ~r{<navPoint id="ode-to-bacon" playOrder="2">}
    assert content =~ ~r{<navPoint id="ode-to-ham" playOrder="3">}
    assert content =~ ~r{<navPoint id="ode-to-egg" playOrder="4">}

    assert content =~ ~r{<content src="bacon.html" />}
    assert content =~ ~r{<content src="ham.html" />}
  end
end
