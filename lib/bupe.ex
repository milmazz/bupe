defmodule BUPE do
  @moduledoc """
  Elixir EPUB generator and parser.
  """

  defmodule Config do
    @moduledoc ~S"""
    Configuration structure that holds all the available options for EPUB.

    ## EPUB specification fields

    * `title` - Represents an instance of a name given to the EPUB Publication.
    * `creator` -  Represents the name of a person, organization, etc.
    responsible for the creation of the content
    * `contributor` - Represents the name of a person, organization, etc. that
    played a secondary role in the creation of the content.
    * `date` - Define the publication date. The publication date is not the
    same as the last modification date. See: [Date and Time Formats][datetime]
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
    (e.g., annotations packaged in EPUB format or a dictionary).

    For more information about other fields as `description`, `format`,
    `coverage`, `publisher`, `relation`, `rights`, `subject`, etc. please see
    `BUPE.Builder.Package` or the [Package Metadata][meta] section of the EPUB
    specification.

    ## Support configuration

    * `files` - List of XHTML files which will be included in the EPUB document
    * `nav` - List of maps which is required to create the EPUB Navigation
      document. See `BUPE.Package.Nav` for more information.

    [meta]: http://www.idpf.org/epub/30/spec/epub30-publications.html#sec-package-metadata
    [datetime]: http://www.w3.org/TR/NOTE-datetime
    """
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
              files: nil,
              nav: nil

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
  end

  @bupe_version Mix.Project.config[:version]

  @doc """
  Returns the BUPE version (used in templates)
  """
  @spec version :: String.t
  def version, do: @bupe_version

  @doc """
  Generates an EPUB v3 document
  """
  @spec build(%Config{}, Path.t, Keyword.t) :: String.t
  def build(config, output, opts \\ []), do: BUPE.Builder.save(config, output, opts)

  @doc """
  Parse and EPUB v3 document
  """
  @spec parse(Path.t) :: String.t | no_return
  def parse(epub_file), do: BUPE.Parser.parse(epub_file)

  def build_config do
    # FIXME: This function should provides default values for %Config{}
  end

  @spec modified_date(%Config{}) :: %Config{}
  def modified_date(config) do
    # TODO: If the user provides a value, we need to check if compatible with ISO8601
    unless config[:modified] do
      dt = DateTime.utc_now() |> DateTime.to_iso8601()
      Map.put(config, :date, dt)
    end
  end
end
