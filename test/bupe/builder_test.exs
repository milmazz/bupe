defmodule BUPE.Builder.BuilderTest do
  use ExUnit.Case

  setup do
    File.rm_rf(tmp_dir())
    File.mkdir_p!(tmp_dir())
  end

  defp tmp_dir do
    Path.expand("../tmp/", __DIR__)
  end

  defp fixtures_dir do
    Path.expand("../fixtures", __DIR__)
  end

  defp nav_config do
    %{
      title: "Sample",
      lang: "en",
      creator: "John Doe",
      published: "Sample",
      date: "2016-06-23",
      unique_identifier: "http://example.com/book/jdoe/1",
      scheme: "URL",
      uid: "http://example.com/book/jdoe/1",
      files: Path.wildcard(fixtures_dir() <> "/*.html"),
      nav: [
        %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.html"},
        %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.html"},
        %{id: "ode-to-egg", label: "3. Ode to Egg", content: "egg.html"}
      ],
      tmp_dir: tmp_dir()
    }
  end

  defp nav_config(config) do
    Map.merge(nav_config(), config)
  end

  test "save epub doc" do
    config = nav_config(%{})

    output = Path.join(tmp_dir(), "sample.epub")
    BUPE.Builder.save(config, output)

    assert File.exists?(output)
  end
end
