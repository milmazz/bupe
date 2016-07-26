defmodule BUPE do
  @moduledoc """
  Elixir EPUB generator and parser
  """

  defmodule Config do
    @moduledoc """
    Configuration structure that holds all the available options for EPUB

    ## EPUB specification

    * `title` -
    * `subtitle` -
    * `creator` -
    * `publisher` -
    * `date` - See:
    * `identifier` -
    * `scheme` -  default: `URL`
    * `uid` -
    * `lang` - default: `"en"` See: http://tools.ietf.org/html/rfc5646

    ## Support configuration

    * `files` -
    * `nav` -

    """
    defstruct title: nil,
              subtitle: nil,
              creator: nil,
              publisher: nil,
              date: nil,
              identifier: nil,
              scheme: "URL",
              uid: nil,
              lang: "en",
              unique_identifier: nil,
              files: nil,
              nav: nil

    defmodule InvalidDate do
      defexception message: "date is invalid"

      @moduledoc """
      Error raised when date is invalid:

        * The modification date must be expressed in Coordinated Universal Time
          (UTC) and must be terminated by the Z time zone indicator.
        * For compliance with EPUB 2 Reading Systems, the date string should conform to
          [Date and Time Formats](

      [1]: http://www.w3.org/TR/NOTE-datetime
      """
    end

    defmodule InvalidLanguage do
      defexception message: "Language is invalid"

      @moduledoc """
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
end
