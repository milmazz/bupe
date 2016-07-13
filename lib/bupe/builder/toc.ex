defmodule BUPE.Builder.TOC do

  alias BUPE.Builder.Templates

  def save(config, output) do
    content = Templates.toc_template(config)
    File.write!(output, content)
  end
end
