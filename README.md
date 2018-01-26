# BUPE

BUPE is an Elixir ePub generator and parser, it supports EPUB v2 and v3.

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
iex(1)> files = "~/book/*.xhtml" |> Path.expand() |> Path.wildcard()
["/Users/dev/book/bacon.xhtml", "/Users/dev/book/egg.xhtml", "/Users/dev/book/ham.xhtml"]
iex(2)> get_id = fn file -> Path.basename(file, ".xhtml") end
#Function<6.99386804/1 in :erl_eval.expr/5>
iex(3)> pages = Enum.map(files, fn file ->
...(3)>   %{href: file, id: get_id.(file), description: file |> get_id.() |> String.capitalize()}
...(3)> end)
[
  %{
    description: "Bacon",
    href: "/Users/dev/book/bacon.xhtml",
    id: "bacon"
  },
  %{
    description: "Egg",
    href: "/Users/dev/book/egg.xhtml",
    id: "egg"
  },
  %{
    description: "Ham",
    href: "/Users/dev/book/ham.xhtml",
    id: "ham"
  }
]
iex(4)> config = %BUPE.Config{
...(4)>  title: "Sample",
...(4)>  language: "en",
...(4)>  creator: "John Doe",
...(4)>  publisher: "Sample",
...(4)>  date: "2016-06-23T06:00:00Z",
...(4)>  unique_identifier: "EXAMPLE",
...(4)>  identifier: "http://example.com/book/jdoe/1",
...(4)>  pages: pages,
...(4)>  nav: nav
...(4)> }
%BUPE.Config{
  audio: [],
  contributor: nil,
  cover: true,
  coverage: nil,
  creator: "John Doe",
  date: "2016-06-23T06:00:00Z",
  description: nil,
  fonts: [],
  format: nil,
  identifier: "http://example.com/book/jdoe/1",
  images: [],
  language: "en",
  logo: nil,
  modified: nil,
  nav: nil,,
  pages: [
    %{
      description: "Bacon",
      href: "/Users/dev/book/bacon.xhtml",
      id: "bacon"
    },
    %{
      description: "Egg",
      href: "/Users/dev/book/egg.xhtml",
      id: "egg"
    },
    %{
      description: "Ham",
      href: "/Users/dev/book/ham.xhtml",
      id: "ham"
    }
  ],
  publisher: "Sample",
  relation: nil,
  rights: nil,
  scripts: [],
  source: nil,
  styles: [],
  subject: nil,
  title: "Sample",
  type: nil,
  unique_identifier: "EXAMPLE",
  version: "3.0"
}
iex(6)> BUPE.build(config, "example.epub")
{:ok, '/Users/dev/example.epub'}
```

See `BUPE.Builder` for more details.

### Parser

If you want to parse an EPUB file you can do the following:

```elixir
iex> BUPE.parse("sample.epub")
%BUPE.Config{
  creator: "John Doe",
  nav: [
    %{idref: 'ode-to-bacon'},
    %{idref: 'ode-to-ham'},
    %{idref: 'ode-to-egg'}
  ],
  pages: [
    %{
      href: 'bacon.xhtml',
      id: 'ode-to-bacon',
      "media-type": 'application/xhtml+xml'
    },
    %{
      href: 'ham.xhtml',
      id: 'ode-to-ham',
      "media-type": 'application/xhtml+xml'
    },
    %{
      href: "egg.xhtml",
      id: 'ode-to-egg',
      "media-type": 'application/xhtml+xml'
    }
  ],
  styles: [
    %{href: 'stylesheet.css', id: 'styles', "media-type": 'text/css'}
  ],
  title: "Sample",
  unique_identifier: "EXAMPLE",
  version: "3.0"
}
```

See `BUPE.Parser` for more details.

## License

BUPE source code is released under Apache 2 License.

Check the [LICENSE](LICENSE) for more information.
