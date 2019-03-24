defmodule BUPE do
  @moduledoc """
  Elixir EPUB generator and parser.
  """

  @bupe_version Mix.Project.config()[:version]

  @doc """
  Returns the BUPE version (used in templates)
  """
  @spec version :: String.t()
  def version, do: @bupe_version

  defdelegate build(config, output, options \\ []), to: BUPE.Builder, as: :run

  defdelegate parse(epub_file), to: BUPE.Parser, as: :run
end
