defmodule BUPE.Config do
  @moduledoc ~S"""
  Configuration struct for building an EPUB.

  Most fields map to the Package Definition metadata, which is the primary source
  of bibliographic and structural information about the publication.

  ## Core EPUB metadata fields

  * `title` - Title of the EPUB publication.
  * `creator` - Person or organization responsible for the content.
  * `contributor` - Person or organization with a secondary role.
  * `date` - Publication date (not the last modification date). See
    [Date and Time Formats][datetime].
  * `modified` - Modification date in UTC, terminated by the `Z` indicator.
  * `identifier` - Identifier such as a UUID, DOI, ISBN, or ISSN. Default: UUID.
  * `language` - Primary language of the publication. Default: `"en"`.
  * `version` - EPUB specification version. Default: `"3.0"`.
  * `unique_identifier` - Identifier unique to this publication.
  * `source` - Source publication this EPUB derives from.
  * `type` - Specialized publication type; see the [EPUB Publication Types
    Registry][types].

  For additional fields such as `description`, `format`, `coverage`,
  `publisher`, `relation`, `rights`, and `subject`, see the
  [Package Metadata][meta] section of the EPUB specification.

  ## Content and assets

  * `pages` - List of XHTML files or `%BUPE.Item{}` entries. Order controls
    navigation order in the EPUB.
  * `styles` - List of CSS files or `%BUPE.Item{}` entries.
  * `scripts` - List of JavaScript files or `%BUPE.Item{}` entries.
  * `images` - List of image files or `%BUPE.Item{}` entries.
  * `cover` - Whether to include a default cover page. Default: `true`.
  * `logo` - Image path for the cover page.

  [meta]: http://www.idpf.org/epub/30/spec/epub30-publications.html#sec-package-metadata
  [datetime]: http://www.w3.org/TR/NOTE-datetime
  [types]: http://idpf.github.io/epub-registries/types/
  """

  alias BUPE.Item

  @type title :: String.t()
  @type creator :: String.t()
  @type contributor :: String.t()

  @type t :: %__MODULE__{
          title: title,
          creator: creator,
          contributor: contributor,
          date: String.t(),
          identifier: String.t(),
          language: String.t(),
          version: String.t(),
          unique_identifier: String.t(),
          source: String.t(),
          type: String.t(),
          modified: String.t(),
          description: String.t(),
          format: String.t(),
          coverage: String.t(),
          publisher: String.t(),
          relation: String.t(),
          rights: String.t(),
          subject: String.t(),
          pages: [Path.t() | Item.t()],
          nav: list(),
          styles: [Path.t() | Item.t()],
          scripts: [Path.t() | Item.t()],
          images: [Path.t() | Item.t()],
          cover: boolean,
          logo: String.t(),
          audio: [map()],
          fonts: [map()],
          toc: [map()]
        }

  @enforce_keys [:title, :pages]
  defstruct [
    :title,
    :creator,
    :contributor,
    :date,
    :identifier,
    :unique_identifier,
    :source,
    :type,
    :modified,
    :description,
    :format,
    :coverage,
    :publisher,
    :relation,
    :rights,
    :subject,
    :logo,
    language: "en",
    version: "3.0",
    pages: [],
    nav: [],
    styles: [],
    scripts: [],
    images: [],
    cover: true,
    audio: [],
    fonts: [],
    toc: []
  ]

  @doc "Creates a new `BUPE.Config` struct from the provided keyword list or map."
  def new(data), do: struct!(__MODULE__, data)
end
