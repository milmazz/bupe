# BUPE

[![Module Version](https://img.shields.io/hexpm/v/bupe.svg)](https://hex.pm/packages/bupe)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/bupe/)
[![Total Download](https://img.shields.io/hexpm/dt/bupe.svg)](https://hex.pm/packages/bupe)
[![License](https://img.shields.io/hexpm/l/bupe.svg)](https://github.com/milmazz/bupe/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/milmazz/bupe.svg)](https://github.com/milmazz/bupe/commits/master)
<!-- MDOC -->
`BUPE` is an Elixir EPUB generator and parser with support for [EPUB] 2 and 3.

## Installation

First, add `:bupe` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bupe, "~> 0.6"}
  ]
end
```

To check the latest release on Hex, run `mix hex.info bupe` or visit the
[`bupe` page on Hex.pm](https://hex.pm/packages/bupe).

Then update your dependencies:

```console
mix deps.get
```

## Usage

### Builder

To create an [EPUB] file:

```elixir
pages = "~/book/*.xhtml" |> Path.expand() |> Path.wildcard()
config = BUPE.Config.new(%{
  title: "Sample",
  language: "en",
  creator: "John Doe",
  publisher: "Sample",
  pages: pages
})
BUPE.build(config, "sample.epub")
# {:ok, '/Users/dev/sample.epub'}
```

If you prefer, you can build the [EPUB] document in memory:

```elixir
BUPE.build(config, "sample.epub", [:memory])
```

For more control over `pages`, you can provide a list of `BUPE.Item` structs
instead of a list of strings:

```elixir
pages = [
  %BUPE.Item{
    href: "/Users/dev/book/bacon.xhtml",
    description: "Ode to Bacon"
  }
]
```

The `description` is used in the EPUB Table of Contents; if you omit it,
`BUPE` derives a default description from the file name.

If a page includes JavaScript, use the `properties` field in `BUPE.Item`:

```elixir
pages = [
  %BUPE.Item{
    href: "/Users/dev/book/bacon.xhtml",
    description: "Ode to Bacon",
    properties: "scripted"
  }
]
```

Keep in mind that if you add the `scripted` property to a page without
JavaScript, you will see warnings from validation tools such as
[EPUBCheck][epubcheck].

See `BUPE.build/3`, `BUPE.Config`, and `BUPE.Item` for details.

### Using the builder via command line

You can build EPUB documents from the command line as follows:

1. Install `BUPE` as an escript:

```console
mix escript.install hex bupe
```

2. Then use it in your projects:

```console
bupe "EPUB_TITLE" -p egg.xhtml -p bacon.xhtml -l path/to/logo.png
```

For more details on the command-line tool, review the usage guide:

```console
bupe --help
```

### Parser

To parse an EPUB file:

```elixir
BUPE.parse("Elixir.epub")
```

See `BUPE.parse/1` for details.

[epub]: https://www.w3.org/publishing/epub3/
[epubcheck]: https://github.com/w3c/epubcheck
<!-- MDOC -->
## Copyright and License

Copyright 2025 Milton Mazzarri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [https://www.apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
