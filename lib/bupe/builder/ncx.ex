defmodule BUPE.Builder.NCX do
  @moduledoc ~S"""
  Navigation Center eXtended definition

  Please keep in mind that the EPUB Navigation Document defined in
  `BUPE.Builder.Nav` supersedes this definition. According to the EPUB
  specification:

  > EPUB 3 Publications may include an NCX (as defined in OPF 2.0.1) for EPUB
  > 2 Reading System forwards compatibility purposes, but EPUB 3 Reading
  > Systems must ignore the NCX.

  """

  alias BUPE.Builder.Templates

  @doc """
  Generates an NCX document compatible with EPUB 2 reading systems
  """
  @spec save(%BUPE.Config{}, Path.t) :: :ok | no_return
  def save(config, output) do
    content = Templates.ncx_template(config)
    File.write!(output, content)
  end
end
