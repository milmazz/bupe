# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.8.1 (2026-08-17)

### Fixed

* Do not render the cover `itemref` in the spine when `cover: false`; the
  spine referenced a manifest item that does not exist, which EPUBCheck
  reports as an error (`RSC-005`).
* Mark the cover image so reading systems actually use it: EPUB 3 manifests
  now carry `properties="cover-image"` on the logo item, and EPUB 2 packages
  now include `<meta name="cover" content="cover-image" />`. Without either,
  the logo was never picked up for library thumbnails.

### Added

* Validate generated EPUBs with [EPUBCheck](https://github.com/w3c/epubcheck)
  in CI: an opt-in integration test builds every EPUB 2/3, cover, and logo
  combination and requires a clean report. All combinations pass EPUBCheck
  5.3.0 with zero errors and zero warnings.

## v0.8.0 (2026-08-17)

### Added

* Validate the `language` tag against the IANA language subtag registry using
  [lang_tags](https://hex.pm/packages/lang_tags); **BUPE.build/3** now raises
  **BUPE.InvalidLanguage** when the tag is invalid (e.g. `"en_US"`). Advisory
  findings — a deprecated tag or a redundant default script, such as
  `"art-lojban"` or `"gsw-Latn"` — are still accepted, since EPUB only
  requires well-formed [BCP 47](https://www.rfc-editor.org/info/bcp47) tags
  and reading systems handle them. (#101)

### Fixed

* Bundle the cover logo into the EPUB archive. `config.logo` was referenced
  by the package document and the title page but never copied into
  `OEBPS/content/`, so the EPUB pointed to a file missing from the archive.
  The logo is now referenced by its base name — fixing logos given as paths,
  e.g. via the CLI's `--logo` option — and a duplicate entry is dropped when
  the same file is also listed in `images`. (#101)

### Changed

* Add Elixir 1.20/OTP 29 to the CI test matrix and update the development
  toolchain.

## v0.7.0 (2026-07-08)

### Fixed

* Render the cover image `media-type` attribute in the package document;
  it was previously always empty.
* Run the CI workflow on the `main` branch (it previously targeted the
  removed `master` branch, so CI never ran) and update stale `master`
  links in the documentation.

### Changed

* **BUPE.build/3** now returns the output path as a `String.t()` instead of a
  charlist.
* Declare an honest minimum Elixir version (`~> 1.17`) and test against a
  matrix of Elixir/OTP versions (1.17/OTP 27 through 1.19/OTP 28) in CI.
  Erlang/OTP 27+ is required because the builder relies on the `:extra`
  option of `:zip.create/3` to produce clean ZIP entries.
* Run Credo, Dialyzer (with a cached PLT), `mix format --check-formatted`,
  and `mix deps.unlock --check-unused` in CI.
* Remove the deprecated `build_embedded` project option.

## v0.6.5 (2025-12-31)

### Added

* Extract media type handling into **BUPE.MediaType**.

### Changed

* Refactor builder implementation.
* Refactor publication item normalization.
* Replace **BUPE.Util** with a focused **BUPE.UUID** module.
* Enable `ex_doc` outdated warning checks in dev dependencies.
* Improve documentation and examples.

## v0.6.4 (2025-12-31)

### Fixed

* Avoid adding extra info to ZIP entries. (#98)

## v0.6.3 (2025-09-21)

### Added

* Extract the table of contents (TOC) while parsing EPUB files.

### Fixed

* Fix content extraction from files directly under the root directory.

### Changed

* Update Elixir/OTP version; minor refactoring.
* Use [saxy](https://hex.pm/packages/saxy) to parse EPUB documents.

## v0.6.2 (2025-05-16)

### Added

* Extract content from associated pages, images, styles, and scripts while parsing EPUB document.

## v0.6.1 (2024-09-26)

### Changed

* Update Elixir/OTP version, minor refactoring
* Improve test suite to use `tmp_dir` tag and avoid flaky tests
* Validate modification dates

## v0.6.0 (2019-03-30)

### Added

* Add CLI interface

## v0.5.1 (2019-03-24)

### Fixed

* Provide an alternative description for `BUPE.Item` in case is missing

## v0.5.0 (2019-03-24)

### Added

* Improve documentation
* Refactor EPUB builder
* Introduce `BUPE.Item` definition
* Fix unit tests after moving exception definitions
* Provide an utility module
* Move `BUPE.Config` and exceptions into its own files
* Revert Elixir version bump

## v0.4.1 (2019-03-21)

### Fixed

* Improve backward compatibility

## v0.4.0 (2019-03-20)

### Added

* Allow to parse/create EPUBs in memory
* README: Update sample for the EPUB Parser
* Split parsing of metadata and manifest sections
* Improve EPUB parsing
* Apply `mix format` to parser
* Better support for UTF-8
* Improve mimetype and zip creation
* Remove some options from the default config
* Add more tests for the Builder
* Allow to opt-out of the default cover page

### Fixed

* Fix example in `BUPE.build/3` docs

## v0.3.0 (2016-12-25)

### Added

* Allow BUPE as dependency in escripts projects

### Fixed

* Include reference to images in the OPF manifest

## v0.2.0 (2016-10-11)

### Added

* Allow to include images, JS and CSS custom files.

## v0.1.0 (2016-08-02)

* Initial release
