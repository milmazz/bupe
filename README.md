# BUPE

[![Build Status](https://travis-ci.org/milmazz/bupe.svg?branch=master)](https://travis-ci.org/milmazz/bupe)

BUPE is a Elixir ePub generator and parser, it supports EPUB v2 and v3.

## Installation

First, add `bupe` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:bupe, "~> 0.1.0"}]
end
```

Then, update your dependencies:

```sh-session
$ mix deps.get
```

## Usage

### Builder

If you want to create an EPUB file you can do the following:

```elixir
iex> config = %BUPE.Config{
...>   title: "Sample",
...>   creator: "John Doe",
...>   unique_identifier: "EXAMPLE",
...>   files: ["bacon.xhtml", "ham.xhtml", "egg.xhtml"],
...>   nav: [
...>     %{id: "ode-to-bacon", label: "1. Ode to Bacon", content: "bacon.xhtml"},
...>     %{id: "ode-to-ham", label: "2. Ode to Ham", content: "ham.xhtml"},
...>     %{id: "ode-to-egg", label: "3. Ode to Egg", content: "egg.xhtml"}
...>   ]
...> }
iex> BUPE.build(config, "food.epub")
```

See `BUPE.Builder` for more details.

### Parser

If you want to parse an EPUB file you can do the following:

```elixir
iex> BUPE.parse("sample.epub")
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

See `BUPE.Parser` for more details.

## License

BUPE source code is released under Apache 2 License.

Check the [LICENSE](LICENSE) for more information.
