# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.6.0 (2019-03-30)

* Add CLI interface

## v0.5.1 (2019-03-24)

### Bug fixes

* Provide an alternative description for `BUPE.Item` in case is missing

## v0.5.0 (2019-03-24)

### Enhancements

* Improve documentation
* Refactor EPUB builder
* Introduce `BUPE.Item` definition
* Fix unit tests after moving exception definitions
* Provide an utility module
* Move BUPE.Config and exceptions into its own files
* Revert Elixir version bump

## v0.4.1 (2019-03-21)

### Bug fixes

* Improve backward compatibility

## v0.4.0 (2019-03-20)

### Enhancements

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

### Bug fixes

* Fix example in `BUPE.Builder` docs

## v0.3.0 (2016-12-25)

### Enhancements

  * Allow BUPE as dependency in escripts projects

### Bug fixes

  * Include reference to images in the OPF manifest

## v0.2.0 (2016-10-11)

### Enhancements

  * Allow to include images, JS and CSS custom files.

## v0.1.0 (2016-08-02)

  * Initial release
