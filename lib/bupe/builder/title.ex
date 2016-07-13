defmodule BUPE.Builder.Title do

  alias BUPE.Builder.Templates

  def save(config, output) do
    content = Templates.title_template(config)
    File.write!(output, content)
  end
end
