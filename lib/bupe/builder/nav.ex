defmodule BUPE.Builder.Nav do

  alias BUPE.Builder.Templates

  def save(config, output) do
    content = Templates.nav_template(config)
    File.write!(output, content)
  end
end
