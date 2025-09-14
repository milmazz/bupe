defmodule BUPE.Config do
  @moduledoc ~S"""
  Configuration structure that holds all the available options for EPUB.

  Most of these fields are used in the Package Definition document, this
  document includes bibliographic and structural metadata about an EPUB
  Publication, and is thus the primary source of information about how to
  process and display it.

  ## EPUB specification fields

  * `title` - Represents an instance of a name given to the EPUB Publication.
  * `creator` -  Represents the name of a person, organization, etc.
  responsible for the creation of the content
  * `contributor` - Represents the name of a person, organization, etc. that
  played a secondary role in the creation of the content.
  * `date` - Define the publication date. The publication date is not the
  same as the last modification date. See: [Date and Time Formats][datetime]
  * `modified` - The modification date must be expressed in Coordinated
  Universal Time (UTC) and must be terminated by the Z time zone indicator.
  * `identifier` - Contains a single identifier associated with the EPUB
  Publication, such as a UUID, DOI, ISBN or ISSN. Default: UUID
  * `language` - Specifies the language used in the contents. Default: `"en"`
  * `version` - Specifies the EPUB specification version to which the
  Publication conforms. Default: "3.0"
  * `unique_identifier` - Specifies a primary identifier that is unique to
  one and only one particular EPUB Publication
  * `source` - Identifies the source publication from which this EPUB
  Publication is derived.
  * `type` - Indicates that the given Publication is of a specialized type
  (e.g., annotations packaged in EPUB format or a dictionary). See the
  [EPUB Publication Types Registry][types] document for more information.

  For more information about other fields as `description`, `format`,
  `coverage`, `publisher`, `relation`, `rights`, `subject`, etc. please see
  the [Package Metadata][meta] section of the EPUB specification.

  ## Support configuration

  * `pages` - List of XHTML files which will be included in the EPUB document,
    please keep in mind that the sequence here will set the navigation order in
    the EPUB document.
  * `styles` - List of CSS files which will be included in the EPUB document
  * `scripts` - List of JS files which will be included in the EPUB document
  * `images` - List of images which will be included in the EPUB document.
  * `cover` - Specifies if you want a default cover page, default: `true`
  * `logo` - Image for the cover page

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

  @doc "Creates a new `BUPE.Config` struct using the given data"
  def new(data), do: struct!(__MODULE__, data)
end
