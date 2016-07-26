# BUPE: An Elixir EPUB generator and parser

If you want to create an EPUB file you can do the following:

```elixir
config = %BUPE.Config{
  title: "Sample",
  creator: "John Doe",
  unique_identifier: "EXAMPLE",
  files: ["bacon.xhtml", "ham.xhtml", "egg.xhtml"],
  nav: [
    %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.xhtml"},
    %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.xhtml"},
    %{id: "ode-to-egg", label: "3. Ode to Egg", content: "egg.xhtml"}
  ]
}
BUPE.Builder.save(config, "food.epub")
```

If you want to parse an EPUB file you can do the following:

```elixir
BUPE.Parser.parse("sample.epub")
%BUPE.Config{
  title: "Sample",
  creator: "John Doe",
  unique_identifier: "EXAMPLE",
  files: ["bacon.xhtml", "ham.xhtml", "egg.xhtml"],
  nav: [
    %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.xhtml"},
    %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.xhtml"},
    %{id: "ode-to-egg", label: "3. Ode to Egg", content: "egg.xhtml"}
  ]
}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `bupe` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:bupe, "~> 0.1.0"}]
    end
    ```

  2. Ensure `bupe` is started before your application:

    ```elixir
    def application do
      [applications: [:bupe]]
    end
    ```

