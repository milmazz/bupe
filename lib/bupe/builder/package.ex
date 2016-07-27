defmodule BUPE.Builder.Package do
  @moduledoc ~S"""
  Package definition builder.

  According to the EPUB specification, the *Package Document* carries
  bibliographic and structural metadata about an EPUB Publication, and is thus
  the primary source of information about how to process and display it.

  The `package` element is the root container of the Package Document and
  encapsulates Publication metadata and resource information.

  ## Required configuration values

  * `version` - Specifies the EPUB specification version to which the
    Publication conforms. Default: "3.0"
  * `unique_identifier` - Specifies a primary identifier that is unique to
    one and only one particular EPUB Publication
  * `identifier` - Contains a single identifier associated with the EPUB
    Publication, such as a UUID, DOI, ISBN or ISSN.
  * `title` - Represents an instance of a name given to the EPUB Publication.
  * `language` - Specifies the language used in the contents
  * `modified` - The modification date must be expressed in Coordinated
    Universal Time (UTC) and must be terminated by the Z time zone indicator.

  ## Optional configuration values

  * `creator` -  Represents the name of a person, organization, etc.
    responsible for the creation of the content
  * `contributor` - Represents the name of a person, organization, etc. that
    played a secondary role in the creation of the content.
  * `date` - Define the publication date. The publication date is not the
    same as the last modification date. See: [Date and Time Formats][datetime]
  * `source` - Identifies the source publication from which this EPUB
    Publication is derived.
  * `type` - Indicates that the given Publication is of a specialized type
    (e.g., annotations packaged in EPUB format or a dictionary).

  For more information about more optional fields as `description`, `format`,
  `coverage`, `publisher`, `relation`, `rights`, `subject`, etc. please see the
  [Package Metadata][meta] section of the EPUB specification.

  [meta]: http://www.idpf.org/epub/30/spec/epub30-publications.html#sec-package-metadata
  [datetime]: http://www.w3.org/TR/NOTE-datetime

  """

  alias BUPE.Builder.Templates

  @doc """
  Generate the package definition document
  """
  @spec save(%BUPE.Config{}, Path.t) :: :ok | no_return
  def save(config, output) do
    content = Templates.content_template(config)
    File.write!(output, content)
  end
end
