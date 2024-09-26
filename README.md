# BUPE

[![Module Version](https://img.shields.io/hexpm/v/bupe.svg)](https://hex.pm/packages/bupe)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/bupe/)
[![Total Download](https://img.shields.io/hexpm/dt/bupe.svg)](https://hex.pm/packages/bupe)
[![License](https://img.shields.io/hexpm/l/bupe.svg)](https://github.com/milmazz/bupe/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/milmazz/bupe.svg)](https://github.com/milmazz/bupe/commits/master)

BUPE is an Elixir ePub generator and parser, it supports EPUB v2 and v3.

## Installation

First, add `:bupe` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bupe, "~> 0.6"}
  ]
end
```

To find out the latest release available on Hex, you can run `mix hex.info bupe` in your shell, or by going to the
[`bupe` page on Hex.pm](https://hex.pm/packages/bupe)

Then, update your dependencies:

```sh-session
$ mix deps.get
```

## Usage

### Builder

If you want to create an EPUB file you can do the following:

```elixir
iex(1)> pages = "~/book/*.xhtml" |> Path.expand() |> Path.wildcard()
["/Users/dev/book/bacon.xhtml", "/Users/dev/book/egg.xhtml", "/Users/dev/book/ham.xhtml"]
iex(2)> config = %BUPE.Config{
...(2)>  title: "Sample",
...(2)>  language: "en",
...(2)>  creator: "John Doe",
...(2)>  publisher: "Sample",
...(2)>  pages: pages
...(2)> }
%BUPE.Config{
  audio: [],
  contributor: nil,
  cover: true,
  coverage: nil,
  creator: "John Doe",
  date: nil,
  description: nil,
  fonts: [],
  format: nil,
  identifier: nil,
  images: [],
  language: "en",
  logo: nil,
  modified: nil,
  nav: [],
  pages: ["/Users/dev/book/bacon.xhtml",
   "/Users/dev/book/egg.xhtml",
   "/Users/dev/book/ham.xhtml"],
  publisher: "Sample",
  relation: nil,
  rights: nil,
  scripts: [],
  source: nil,
  styles: [],
  subject: nil,
  title: "Sample",
  type: nil,
  unique_identifier: nil,
  version: "3.0"
}
iex(3)> BUPE.build(config, "sample.epub")
{:ok, '/Users/dev/sample.epub'}
```

If you prefer, you can build the EPUB document in memory doing the following:

```elixir
iex(4)> BUPE.build(config, "sample.epub", [:memory])
{:ok,
 {'/Users/dev/sample.epub',
  <<80, 75, 3, 4, 20, 0, 0, 0, 0, 0, 61, 123, 119, 78, 111, 97, 171, 44, 20, 0,
    0, 0, 20, 0, 0, 0, 8, 0, 0, 0, 109, 105, 109, 101, 116, 121, 112, 101, 97,
    112, 112, 108, 105, 99, 97, 116, ...>>}}
```

If you want to have more control over the `pages` configuration, instead of
passing a list of string, you can provide a list of `%BUPE.Item{}` like this:

```elixir
iex(1)> pages = [%BUPE.Item{href: "/Users/dev/book/bacon.xhtml", description: "Ode to Bacon"}]
[
  %BUPE.Item{
    description: "Ode to Bacon",
    duration: nil,
    fallback: nil,
    href: "/Users/dev/book/bacon.xhtml",
    id: nil,
    media_overlay: nil,
    media_type: nil,
    properties: ""
  }
]
```

The given `description` will be used in the _Table of Contents_ of EPUB
document, otherwise `BUPE` will provide a default description based on the file
name.

If your page include JavaScript, is recommended that you use the `properties`
field from `%BUPE.Item{}` like this:

```elixir
iex(2)> pages = [%BUPE.Item{href: "/Users/dev/book/bacon.xhtml", description: "Ode to Bacon", properties: "scripted"}]
[
  %BUPE.Item{
    description: "Ode to Bacon",
    duration: nil,
    fallback: nil,
    href: "/Users/dev/book/bacon.xhtml",
    id: nil,
    media_overlay: nil,
    media_type: nil,
    properties: "scripted"
  }
]
```

Keep in mind that if you put the `scripted` property on a page that does not
have any JavaScript, you will get warnings from validation tools such as
[EPUBCheck][epubcheck].

See `BUPE.Builder`, `BUPE.Config`, and `BUPE.Item` for more details.

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
iex> BUPE.parse("sample.epub")
%BUPE.Config{
  audio: nil,
  contributor: nil,
  cover: true,
  coverage: nil,
  creator: "John Doe",
  date: nil,
  description: nil,
  fonts: nil,
  format: nil,
  identifier: "urn:uuid:bc864bda-1a0b-4014-a72f-30f6dc60e120",
  images: nil,
  language: "en",
  logo: nil,
  modified: "2019-03-23T20:22:20Z",
  nav: [
    %{idref: 'cover', linear: 'no'},
    %{idref: 'nav'},
    %{idref: 'pages-ecbedca7-f77e-46b6-8fe2-99718d00c903'},
    %{idref: 'pages-59ad8356-e46d-4328-b7cc-e81af2880c3a'},
    %{idref: 'pages-1d3ee5e3-cf45-4e45-bd79-8a931e293584'}
  ],
  pages: [
    %{
      href: 'nav.xhtml',
      id: 'nav',
      "media-type": 'application/xhtml+xml',
      properties: 'nav'
    },
    %{href: 'title.xhtml', id: 'cover', "media-type": 'application/xhtml+xml'},
    %{
      href: 'content/bacon.xhtml',
      id: 'pages-ecbedca7-f77e-46b6-8fe2-99718d00c903',
      "media-type": 'application/xhtml+xml',
      properties: 'scripted'
    },
    %{
      href: 'content/egg.xhtml',
      id: 'pages-59ad8356-e46d-4328-b7cc-e81af2880c3a',
      "media-type": 'application/xhtml+xml',
      properties: 'scripted'
    },
    %{
      href: 'content/ham.xhtml',
      id: 'pages-1d3ee5e3-cf45-4e45-bd79-8a931e293584',
      "media-type": 'application/xhtml+xml',
      properties: 'scripted'
    }
  ],
  publisher: "Sample",
  relation: nil,
  rights: nil,
  scripts: nil,
  source: nil,
  styles: [%{href: 'css/stylesheet.css', id: 'css', "media-type": 'text/css'}],
  subject: nil,
  title: "Sample",
  type: nil,
  unique_identifier: "BUPE",
  version: "3.0"
}
```

See `BUPE.Parser` for more details.

## Copyright and License

Copyright 2024 Milton Mazzarri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [https://www.apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[epubcheck]: https://github.com/w3c/epubcheck
