defmodule BUPE.InvalidDate do
  defexception message: "date is invalid"

  @moduledoc ~S"""
  Raised when an EPUB date value is invalid.

  * The modification date must be expressed in Coordinated Universal Time
    (UTC) and must be terminated by the `Z` time zone indicator.
  * For EPUB 2 reading system compatibility, the date string should follow
    [Date and Time Formats][datetime].

  [datetime]: http://www.w3.org/TR/NOTE-datetime
  """
end

defmodule BUPE.InvalidLanguage do
  defexception message: "Language is invalid"

  @moduledoc ~S"""
  Raised when the language tag is invalid.

  The language must be a valid IETF language tag (BCP 47); see [RFC 5646][rfc5646]
  for syntax and examples.

  [rfc5646]: https://www.rfc-editor.org/rfc/rfc5646
  """
end

defmodule BUPE.InvalidVersion do
  defexception message: "invalid EPUB version, expected '2.0' or '3.0'"

  @moduledoc ~S"""
  Raised when an unsupported EPUB version is provided.

  Accepted values are `"2.0"` and `"3.0"`.
  """
end

defmodule BUPE.InvalidExtensionName do
  defexception message: "invalid file extension name"

  @moduledoc ~S"""
  Raised when a content document file extension is invalid.

  * For EPUB 3, XHTML content documents must use the `.xhtml` extension.
  * For EPUB 2, HTML content documents may use `.html`, `.htm`, or `.xhtml`.
  """
end
