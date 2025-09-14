# BUPE

[![Module Version](https://img.shields.io/hexpm/v/bupe.svg)](https://hex.pm/packages/bupe)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/bupe/)
[![Total Download](https://img.shields.io/hexpm/dt/bupe.svg)](https://hex.pm/packages/bupe)
[![License](https://img.shields.io/hexpm/l/bupe.svg)](https://github.com/milmazz/bupe/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/milmazz/bupe.svg)](https://github.com/milmazz/bupe/commits/master)
<!-- MDOC -->
`BUPE` is an Elixir ePub generator and parser, it supports [EPUB] v2 and v3.

## Installation

First, add `:bupe` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bupe, "~> 0.6"}
  ]
end
```

To find out the latest release available on Hex, you can run `mix hex.info bupe`
in your shell, or by going to the [`bupe` page on Hex.pm](https://hex.pm/packages/bupe)

Then, update your dependencies:

```console
mix deps.get
```

## Usage

### Builder

If you want to create an [EPUB] file you can do the following:

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

If you prefer, you can build the [EPUB] document in memory doing the following:

```elixir
BUPE.build(config, "sample.epub", [:memory])
```

If you want more control over the `pages` configuration, instead of
passing a list of strings, you can provide a list of `BUPE.Item` struct like this:

```elixir
pages = [%BUPE.Item{href: "/Users/dev/book/bacon.xhtml", description: "Ode to Bacon"}]
```

The given `description` will be used in the _Table of Contents_ of [EPUB]
document, otherwise `BUPE` will provide a default description based on the file
name.

If your page include JavaScript, is recommended that you use the `properties`
field from `BUPE.Item` like this:

```elixir
pages = [%BUPE.Item{href: "/Users/dev/book/bacon.xhtml", description: "Ode to Bacon", properties: "scripted"}]
```

Keep in mind that if you put the `scripted` property on a page that does not
have any JavaScript, you will get warnings from validation tools such as
[EPUBCheck][epubcheck].

See `BUPE.build/3`, `BUPE.Config`, and `BUPE.Item` for more details.

### Using the builder via command line

You can build EPUB documents using the command line as follows:

1. Install `BUPE` as an escript:

```console
mix escript.install hex bupe
```

2. Then you are ready to use it in your projects:

```console
bupe "EPUB_TITLE" -p egg.xhtml -p bacon.xhtml -l path/to/logo.png
```

For more details about using the command line tool, review the usage guide:

```console
bupe --help
```

### Parser

If you want to parse an EPUB file you can do the following:

```elixir
BUPE.parse("Elixir.epub")
```

See `BUPE.parse/1` for more details.

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
