# Changelog

## v0.5.1

### Bug fixes

* Provide an alternative description for `BUPE.Item` in case is missing

## v0.5.0

### Enhancements

* Improve documentation
* Refactor EPUB builder
* Introduce `BUPE.Item` definition
* Fix unit tests after moving exception definitions
* Provide an utility module
* Move BUPE.Config and exceptions into its own files
* Revert Elixir version bump

## v0.4.1

### Bug fixes

* Improve backward compatibility

## v0.4.0

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

## 0.3.0

### Enhancements

  * Allow BUPE as dependency in escripts projects

### Bug fixes

  * Include reference to images in the OPF manifest

## v0.2.0

### Enhancements

  * Allow to include images, JS and CSS custom files.

## v0.1.0

  * Initial release
