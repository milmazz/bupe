defmodule BUPE.Builder.Nav do
  @moduledoc ~S"""
  Navigation Document Definition

  The TOC nav element defines the primary navigation hierarchy of the document.
  It conceptually corresponds to a table of contents in a printed work.

  For more information please see: [EPUB Navigation Document Definition][nav]

  [nav]: http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def
  
  """

  alias BUPE.Builder.Templates

  @doc """
  Generate the navigation document definition
  """
  @spec save(%BUPE.Config{}, Path.t) :: :ok | no_return
  def save(config, output) do
    content = Templates.nav_template(config)
    File.write!(output, content)
  end
end
