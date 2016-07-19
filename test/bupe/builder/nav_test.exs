defmodule BUPE.Builder.NavTest do
  use BUPETest.Case, async: true

  test "save nav template" do
    config = config(%{})
    output = "#{tmp_dir()}/nav.html"

    BUPE.Builder.Nav.save(config, output)

    content = File.read!(output)
    assert content =~ ~r{<li><a href="bacon.html">1. Ode to Bacon</a></li>}
    assert content =~ ~r{<li><a href="ham.html">2. Ode to Ham</a></li>}
    assert content =~ ~r{<li><a href="egg.html">3. Ode to Egg</a></li>}
  end
end
