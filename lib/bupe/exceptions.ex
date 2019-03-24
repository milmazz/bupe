defmodule BUPE.InvalidDate do
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

defmodule BUPE.InvalidLanguage do
  defexception message: "Language is invalid"

  @moduledoc ~S"""
  Error raised when the language is invalid, must be one of the tags for
  identifying languages, please see [RFC5646][] for more details.

  [RFC5646]: http://www.w3.org/TR/NOTE-datetime

  """
end

defmodule BUPE.InvalidVersion do
  defexception message: "invalid EPUB version, expected '2.0' or '3.0'"

  @moduledoc ~S"""
  Error raised when the given EPUB version is invalid, must be "2.0" or "3.0"

  """
end

defmodule BUPE.InvalidExtensionName do
  defexception message: "invalid file extension name"

  @moduledoc ~S"""
  Error raised when a file extension name is invalid:

  * For EPUB 3 XHTML content document file names should have the extension
    `.xhtml`.
  * For EPUB 2, HTML file name should have the extension `.html`, `.htm` or
    `.xhtml`

  """
end
