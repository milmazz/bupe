defmodule BUPE.Builder.TOCTest do
  use ExUnit.Case

  setup do
    File.rm_rf(tmp_dir())
    File.mkdir_p!(tmp_dir())
  end

  defp tmp_dir do
    Path.expand("../../tmp/", __DIR__)
  end

  defp toc_config do
    %{
      lang: "en",
      title: "Sample",
      nav: [
        %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.html"},
        %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.html"},
        %{id: "ode-to-egg", label: "3. Ode to Egg", content: "egg.html"}
      ],
      uid: "98765433"
    }
  end

  defp toc_config(config) do
    Map.merge(toc_config(), config)
  end

  test "save toc template" do
    config = toc_config(%{})
    output = "#{tmp_dir()}/toc.html"

    BUPE.Builder.TOC.save(config, output)

    content = File.read!("#{output}")

    assert content =~ ~r{<navPoint id="ode-to-bacon" playOrder="2">}
    assert content =~ ~r{<navPoint id="ode-to-ham" playOrder="3">}
    assert content =~ ~r{<navPoint id="ode-to-egg" playOrder="4">}

    assert content =~ ~r{<content src="bacon.html" />}
    assert content =~ ~r{<content src="ham.html" />}
  end
end
