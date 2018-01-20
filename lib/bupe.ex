defmodule BUPE do
  @moduledoc """
  Elixir EPUB generator and parser.
  """

  defmodule Config do
    @moduledoc ~S"""
    Configuration structure that holds all the available options for EPUB.

    Most of this fields are used in the Package Definition document, this
    document carries bibliographic and structural metadata about an EPUB
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

    * `pages` - List of XHTML files which will be included in the EPUB document
    * `nav` - List of maps which is required to create the EPUB Navigation
      document.
    * `styles` - List of CSS files which will be included in the EPUB document
    * `scripts` - List of JS files which will be included in the EPUB document
    * `images` - List of images which will be included in the EPUB document, all
      the images will be located under the `assets` directory.
    * `cover` - Specifies if you want a default cover page, default: true
    * `logo` - Image for the cover page

    [meta]: http://www.idpf.org/epub/30/spec/epub30-publications.html#sec-package-metadata
    [datetime]: http://www.w3.org/TR/NOTE-datetime
    [types]: http://idpf.github.io/epub-registries/types/
    """

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
            pages: [Path.t() | map() | {Path.t(), Path.t()}],
            nav: list(),
            styles: [Path.t() | map()],
            scripts: [Path.t() | map()],
            images: [Path.t() | map()],
            cover: boolean,
            logo: String.t(),
            extras: Keyword.t(),
            audio: [map()],
            fonts: [map()]
          }

    @enforce_keys [:title, :pages, :nav]
    defstruct title: nil,
              creator: nil,
              contributor: nil,
              date: nil,
              identifier: nil,
              language: "en",
              version: "3.0",
              unique_identifier: nil,
              source: nil,
              type: nil,
              modified: nil,
              description: nil,
              format: nil,
              coverage: nil,
              publisher: nil,
              relation: nil,
              rights: nil,
              subject: nil,
              pages: [],
              nav: [],
              styles: [],
              scripts: [],
              images: [],
              cover: true,
              logo: nil,
              extras: [],
              audio: [],
              fonts: []

    defmodule InvalidDate do
      defexception message: "date is invalid"

      @moduledoc ~S"""
      Error raised when date is invalid:

      * The modification date must be expressed in Coordinated Universal Time
        (UTC) and must be terminated by the Z time zone indicator.
      * For compliance with EPUB 2 Reading Systems, the date string should
        conform to [Date and Time Formats][datetime]

      [datetime]: http://www.w3.org/TR/NOTE-datetime
      """
    end

    defmodule InvalidLanguage do
      defexception message: "Language is invalid"

      @moduledoc ~S"""
      Error raised when the language is invalid, must be one of the tags for
      identifying languages, please see [RFC5646][] for more details.

      [RFC5646]: http://www.w3.org/TR/NOTE-datetime

      """
    end

    defmodule InvalidVersion do
      defexception message: "invalid EPUB version, expected '2.0' or '3.0'"

      @moduledoc ~S"""
      Error raised when the given EPUB version is invalid, must be "2.0" or "3.0"

      """
    end

    defmodule InvalidExtensionName do
      defexception message: "invalid file extension name"

      @moduledoc ~S"""
      Error raised when a file extension name is invalid:

      * For EPUB 3 XHTML content document file names should have the extension
        `.xhtml`.
      * For EPUB 2, HTML file name should have the extension `.html`, `.htm` or
        `.xhtml`

      """
    end
  end

  @bupe_version Mix.Project.config()[:version]

  @doc """
  Returns the BUPE version (used in templates)
  """
  @spec version :: String.t()
  def version, do: @bupe_version

  @doc """
  Generates an EPUB v3 document
  """
  @spec build(Config.t(), Path.t()) :: String.t() | no_return
  def build(config, output), do: BUPE.Builder.save(config, output)

  @doc """
  Parse and EPUB v3 document
  """
  @spec parse(Path.t()) :: Config.t() | no_return
  def parse(epub_file), do: BUPE.Parser.parse(epub_file)
end
