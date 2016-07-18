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
  end

  @bupe_version Mix.Project.config[:version]

  @doc """
  Returns the BUPE version (used in templates)
  """
  @spec version :: String.t
  def version, do: @bupe_version
end
