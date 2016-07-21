defmodule BUPE.Builder.NavTest do
  use BUPETest.Case, async: true

  test "save nav template" do
    config = config(%{})
    output = "#{tmp_dir()}/nav.xhtml"

    BUPE.Builder.Nav.save(config, output)

    content = File.read!(output)
    assert content =~ ~r{<li><a href="content/bacon.xhtml">1. Ode to Bacon</a></li>}
    assert content =~ ~r{<li><a href="content/ham.xhtml">2. Ode to Ham</a></li>}
    assert content =~ ~r{<li><a href="content/egg.xhtml">3. Ode to Egg</a></li>}
  end
end
