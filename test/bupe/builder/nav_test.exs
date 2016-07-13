defmodule BUPE.Builder.NavTest do
  use ExUnit.Case

  setup do
    File.rm_rf(tmp_dir())
    File.mkdir_p!(tmp_dir())
  end

  defp tmp_dir do
    Path.expand("../../tmp/", __DIR__)
  end

  defp nav_config do
    %{
      lang: "en",
      title: "Sample",
      nav: [
        %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.html"},
        %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.html"},
        %{id: "ode-to-egg", label: "3. Ode to Egg", content: "egg.html"}
      ]
    }
  end

  defp nav_config(config) do
    Map.merge(nav_config(), config)
  end

  test "save nav template" do
    config = nav_config(%{})
    output = "#{tmp_dir()}/nav.html"

    BUPE.Builder.Nav.save(config, output)

    content = File.read!("#{output}")
    assert content =~ ~r{<li><a href="bacon.html">1. Ode to Bacon</a></li>}
    assert content =~ ~r{<li><a href="ham.html">2. Ode to Ham</a></li>}
    assert content =~ ~r{<li><a href="egg.html">3. Ode to Egg</a></li>}
  end
end
