defmodule BUPETest.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  setup do
    File.rm_rf(tmp_dir())
    File.mkdir_p!(tmp_dir())
  end

  def tmp_dir do
    Path.expand("../tmp", __DIR__)
  end

  def tmp_dir(path) do
    Path.join(tmp_dir(), path)
  end

  def fixtures_dir do
    Path.expand("../fixtures", __DIR__)
  end

  def fixtures_dir(path) do
    Path.join(fixtures_dir(), path)
  end

  def config do
    %BUPE.Config{
      title: "Sample",
      language: "en",
      creator: "John Doe",
      publisher: "Sample",
      modified: "2016-06-23T06:00:00Z",
      unique_identifier: "EXAMPLE",
      identifier: "http://example.com/book/jdoe/1",
      files: Path.wildcard(fixtures_dir() <> "/*.xhtml"),
      nav: [
        %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.xhtml"},
        %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.xhtml"},
        %{id: "ode-to-egg", label: "3. Ode to Egg", content: "egg.xhtml"}
      ],
      extras: [
        tmp_dir: tmp_dir()
      ]
    }
  end
end
