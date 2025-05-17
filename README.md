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
mix deps.get
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
iex(1)> BUPE.parse "Elixir.epub"
%BUPE.Config{
  title: "Elixir - 1.18.3",
  creator: nil,
  contributor: nil,
  date: nil,
  identifier: "urn:uuid:4f88c473-7742-7960-977e-8651832447a5",
  unique_identifier: "project-Elixir",
  source: nil,
  type: nil,
  modified: "2025-03-06T10:06:03Z",
  description: nil,
  format: nil,
  coverage: nil,
  publisher: nil,
  relation: nil,
  rights: nil,
  subject: nil,
  logo: nil,
  language: "en",
  version: "3.0",
  pages: [
    %BUPE.Item{
      duration: nil,
      fallback: nil,
      href: "nav.xhtml",
      id: "nav",
      media_overlay: nil,
      media_type: "application/xhtml+xml",
      description: nil,
      properties: "nav scripted",
      content: "<!DOCTYPE html>\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\"\n      xmlns:epub=\"http://www.idpf.org/2007/ops\">\n  <head>\n    <meta charset=\"utf-8\" />\n    <title>Table Of Contents - Elixir v1.18.3</title>\n    <meta name=\"generator\" content=\"ExDoc v0.37.2\" />\n    <link type=\"text/css\" rel=\"stylesheet\" href=\"dist/epub-elixir-FNUUKFP7.css\" />\n    <script src=\"dist/epub-4WIP524F.js\"></script>\n\n  </head>\n  <body class=\"content-inner\">\n\n    <h1>Table of contents</h1>\n    <nav epub:type=\"toc\">\n      <ol>\n\n\n\n      <li><a href=\"changelog.xhtml\">Changelog for Elixir v1.18</a></li>\n\n\n\n\n    <li><span>Getting started</span>\n      <ol>\n\n\n      <li><a href=\"introduction.xhtml\">Introduction</a></li>\n\n      <li><a href=\"basic-types.xhtml\">Basic types</a></li>\n\n      <li><a href=\"lists-and-tuples.xhtml\">Lists and tuples</a></li>\n\n      <li><a href=\"pattern-matching.xhtml\">Pattern matching</a></li>\n\n      <li><a href=\"case-cond-and-if.xhtml\">case, cond, and if</a></li>\n\n      <li><a href=\"anonymous-functions.xhtml\">Anonymous functions</a></li>\n\n      <li><a href=\"binaries-strings-and-charlists.xhtml\">Binaries, strings, and charlists</a></li>\n\n      <li><a href=\"keywords-and-maps.xhtml\">Keyword lists and maps</a></li>\n\n      <li><a href=\"modules-and-functions.xhtml\">Modules and functions</a></li>\n\n      <li><a href=\"recursion.xhtml\">Recursion</a></li>\n\n      <li><a href=\"enumerable-and-streams.xhtml\">Enumerables and Streams</a></li>\n\n      <li><a href=\"processes.xhtml\">Processes</a></li>\n\n      <li><a href=\"io-and-the-file-system.xhtml\">IO and the file system</a></li>\n\n      <li><a href=\"alias-require-and-import.xhtml\">alias, require, import, and use</a></li>\n\n      <li><a href=\"module-attributes.xhtml\">Module attributes</a></li>\n\n      <li><a href=\"structs.xhtml\">Structs</a></li>\n\n      <li><a href=\"protocols.xhtml\">Protocols</a></li>\n\n      <li><a href=\"comprehensions.xhtml\">Comprehensions</a></li>\n\n      <li><a href=\"sigils.xhtml\">Sigils</a></li>\n\n      <li><a href=\"try-catch-and-rescue.xhtml\">try, catch, and rescue</a></li>\n\n      <li><a href=\"writing-documentation.xhtml\">Writing documentation</a></li>\n\n      <li><a href=\"optional-syntax.xhtml\">Optional syntax sheet</a></li>\n\n      <li><a href=\"erlang-libraries.xhtml\">Erlang libraries</a></li>\n\n      <li><a href=\"debugging.xhtml\">Debugging</a></li>\n\n\n      </ol>\n    </li>\n\n\n\n    <li><span>Cheatsheets</span>\n      <ol>\n\n\n      <li><a href=\"enum-cheat.xhtml\">Enum cheatsheet</a></li>\n\n\n      </ol>\n    </li>\n\n\n\n    <li><span>Anti-patterns</span>\n      <ol>\n\n\n      <li><a href=\"what-anti-patterns.xhtml\">What are anti-patterns?</a></li>\n\n      <li><a href=\"code-anti-patterns.xhtml\">Code-related anti-patterns</a></li>\n\n      <li><a href=\"design-anti-patterns.xhtml\">Design-related anti-patterns</a></li>\n\n      <li><a href=\"process-anti-patterns.xhtml\">Process-related anti-patterns</a></li>\n\n      <li><a href=\"macro-anti-patterns.xhtml\">Meta-programming anti-patterns</a></li>\n\n\n      </ol>\n    </li>\n\n\n\n    <li><span>Meta-programming</span>\n      <ol>\n\n\n      <li><a href=\"quote-and-unquote.xhtml\">Quote and unquote</a></li>\n\n      <li><a href=\"macros.xhtml\">Macros</a></li>\n\n      <li><a href=\"domain-specific-languages.xhtml\">Domain-Specific Languages (DSLs)</a></li>\n\n\n      </ol>\n    </li>\n\n\n\n    <li><span>Mix &amp; OTP</span>\n      <ol>\n\n\n      <li><a href=\"introduction-to-mix.xhtml\">Introduction to Mix</a></li>\n\n      <li><a href=\"agents.xhtml\">Simple state management with agents</a></li>\n\n      <li><a href=\"genservers.xhtml\">Client-server communication with GenServer</a></li>\n\n      <li><a href=\"supervisor-and-application.xhtml\">Supervision trees and applications</a></li>\n\n      <li><a href=\"dynamic-supervisor.xhtml\">Supervising dynamic children</a></li>\n\n      <li><a href=\"erlang-term-storage.xhtml\">Speeding up with ETS</a></li>\n\n      <li><a href=\"dependencies-and-umbrella-projects.xhtml\">Dependencies and umbrella projects</a></li>\n\n      <li><a href=\"task-and-gen-tcp.xhtml\">Task and gen_tcp</a></li>\n\n      <li><a href=\"docs-tests-and-with.xhtml\">Doctests, patterns, and wit" <> ...
    },
    %BUPE.Item{duration: nil, fallback: nil, href: "debugging.xhtml", ...},
    %BUPE.Item{duration: nil, fallback: nil, ...},
    %BUPE.Item{duration: nil, ...},
    %BUPE.Item{...},
    ...
  ],
  nav: [
    %{idref: "cover"},
    %{idref: "nav"},
    %{idref: "changelog"},
    %{idref: "introduction"},
    %{idref: "basic-types"},
    %{idref: "lists-and-tuples"},
    %{idref: "pattern-matching"},
    %{idref: "case-cond-and-if"},
    %{idref: "anonymous-functions"},
    %{idref: "binaries-strings-and-charlists"},
    %{idref: "keywords-and-maps"},
    %{idref: "modules-and-functions"},
    %{idref: "recursion"},
    %{idref: "enumerable-and-streams"},
    %{idref: "processes"},
    %{idref: "io-and-the-file-system"},
    %{idref: "alias-require-and-import"},
    %{idref: "module-attributes"},
    %{idref: "structs"},
    %{idref: "protocols"},
    %{idref: "comprehensions"},
    %{idref: "sigils"},
    %{idref: "try-catch-and-rescue"},
    %{idref: "writing-documentation"},
    %{idref: "optional-syntax"},
    %{idref: "erlang-libraries"},
    %{idref: "debugging"},
    %{idref: "enum-cheat"},
    %{...},
    ...
  ],
  styles: [
    %BUPE.Item{
      duration: nil,
      fallback: nil,
      href: "dist/epub-elixir-FNUUKFP7.css",
      id: "epub-elixir-fnuukfp7-css",
      media_overlay: nil,
      media_type: "text/css",
      description: nil,
      properties: nil,
      content: ":root{--main: hsl(250, 68%, 69%);--mainDark: hsl(250, 68%, 59%);--mainDarkest: hsl(250, 68%, 49%);--mainLight: hsl(250, 68%, 74%);--mainLightest: hsl(250, 68%, 79%);--searchBarFocusColor: #8E7CE6;--searchBarBorderColor: rgba(142, 124, 230, .25);--link-color: var(--mainDark);--link-visited-color: var(--mainDarkest)}body.dark{--link-color: var(--mainLightest);--link-visited-color: var(--mainLight)}:root{--content-width: 949px;--content-gutter: 60px;--borderRadius-lg: 14px;--borderRadius-base: 8px;--borderRadius-sm: 3px;--navTabBorderWidth: 2px;--sansFontFamily: \"Lato\", system-ui, Segoe UI, Roboto, Helvetica, Arial, sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\";--monoFontFamily: ui-monospace, SFMono-Regular, Consolas, Liberation Mono, Menlo, monospace;--baseLineHeight: 1.5em;--gray25: hsl(207, 43%, 98%);--gray50: hsl(207, 43%, 96%);--gray100: hsl(212, 33%, 91%);--gray200: hsl(210, 29%, 88%);--gray300: hsl(210, 26%, 84%);--gray400: hsl(210, 21%, 64%);--gray450: hsl(210, 21%, 49%);--gray500: hsl(210, 21%, 34%);--gray600: hsl(210, 27%, 26%);--gray700: hsl(212, 35%, 17%);--gray750: hsl(214, 46%, 14%);--gray800: hsl(216, 52%, 11%);--gray800-opacity-0: hsla(216, 52%, 11%, 0%);--gray850: hsl(216, 63%, 8%);--gray900: hsl(218, 73%, 4%);--gray900-opacity-50: hsla(218, 73%, 4%, 50%);--gray900-opacity-0: hsla(218, 73%, 4%, 0%);--coldGrayFaint: hsl(240, 5%, 97%);--coldGrayLight: hsl(240, 5%, 88%);--coldGray-lightened-10: hsl(240, 5%, 56%);--coldGray: hsl(240, 5%, 46%);--coldGray-opacity-10: hsla(240, 5%, 46%, 10%);--coldGrayDark: hsl(240, 5%, 28%);--coldGrayDim: hsl(240, 5%, 18%);--yellowLight: hsl(43, 100%, 95%);--yellowDark: hsl(44, 100%, 15%);--yellow: hsl(60, 100%, 43%);--green-lightened-10: hsl(90, 100%, 45%);--green: hsl(90, 100%, 35%);--white: hsl(0, 0%, 100%);--white-opacity-50: hsla(0, 0%, 100%, 50%);--white-opacity-10: hsla(0, 0%, 100%, 10%);--white-opacity-0: hsla(0, 0%, 100%, 0%);--black: hsl(0, 0%, 0%);--black-opacity-10: hsla(0, 0%, 0%, 10%);--black-opacity-50: hsla(0, 0%, 0%, 50%);--orangeDark: hsl(30, 90%, 40%);--orangeLight: hsl(30, 80%, 50%);--text-xs: .75rem;--text-sm: .875rem;--text-md: 1rem;--text-lg: 1.125rem;--text-xl: 1.25rem;--transition-duration: .15s;--transition-timing: cubic-bezier(.4, 0, .2, 1);--transition-all: all var(--transition-duration) var(--transition-timing);--transition-colors: color var(--transition-duration) var(--transition-timing), background-color var(--transition-duration) var(--transition-timing), border-color var(--transition-duration) var(--transition-timing), text-decoration-color var(--transition-duration) var(--transition-timing), fill var(--transition-duration) var(--transition-timing), stroke var(--transition-duration) var(--transition-timing);--transition-opacity: opacity var(--transition-duration) var(--transition-timing)}@media screen and (max-width: 768px){:root{--content-width: 100%;--content-gutter: 20px}}option{background-color:var(--sidebarBackground)}:root{--background: var(--white);--contrast: var(--black);--textBody: var(--gray800);--textHeaders: var(--gray900);--textDetailAccent: var(--mainLight);--textDetailBackground: var(--coldGrayFaint);--iconAction: var(--coldGray);--iconActionHover: var(--gray800);--blockquoteBackground: var(--coldGrayFaint);--blockquoteBorder: var(--coldGrayLight);--tableHeadBorder: var(--gray100);--tableBodyBorder: var(--gray50);--warningBackground: hsl( 33, 100%, 97%);--warningHeadingBackground: hsl( 33, 87%, 64%);--warningHeading: var(--black);--errorBackground: hsl( 7, 81%, 96%);--errorHeadingBackground: hsl( 6, 80%, 60%);--errorHeading: var(--white);--infoBackground: hsl(206, 91%, 96%);--infoHeadingBackground: hsl(213, 92%, 62%);--infoHeading: var(--white);--neutralBackground: hsl(212, 29%, 92%);--neutralHeadingBackground: hsl(220, 43%, 11%);--neutralHeading: var(--white);--tipBackground: hsl(142, 31%, 93%);--tipHeadingBackground: hsl(134, 39%, 36%);--tipHeading: var(--white);--fnSpecAttr: var(--coldGray);--fnDeprecated: var(--yellowLight);--blink: var(--yellowLight);--codeBackground: var(--gray25);--codeBorder: var(--gray100);--codeScroll" <> ...
    }
  ],
  scripts: [],
  images: [
    %BUPE.Item{
      duration: nil,
      fallback: nil,
      href: "assets/kv-observer.png",
      id: "kv-observer-png",
      media_overlay: nil,
      media_type: "image/png",
      description: nil,
      properties: nil,
      content: <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
        ...>>
    }
  ],
  cover: true,
  audio: nil,
  fonts: nil,
  toc: nil
}
```

See `BUPE.parse/1` for more details.

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

[epubcheck]: https://github.com/w3c/epubcheck
