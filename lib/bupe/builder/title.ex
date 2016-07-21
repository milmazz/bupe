defmodule BUPE.Builder.Title do

  alias BUPE.Builder.Templates

  @spec save(%BUPE.Config{}, Path.t) :: :ok | no_return
  def save(config, output) do
    content = Templates.title_template(config)
    File.write!(output, content)
  end
end
