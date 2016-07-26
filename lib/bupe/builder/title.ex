defmodule BUPE.Builder.Title do
  @moduledoc """
  Cover page definition for the EPUB document
  """

  alias BUPE.Builder.Templates

  @doc """
  Generates a cover page for the EPUB document
  """
  @spec save(%BUPE.Config{}, Path.t) :: :ok | no_return
  def save(config, output) do
    content = Templates.title_template(config)
    File.write!(output, content)
  end
end
