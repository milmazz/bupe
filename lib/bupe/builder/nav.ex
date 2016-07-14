defmodule BUPE.Builder.Nav do
  @moduledoc """
  Navigation Document Definition

  The TOC nav element defines the primary navigation hierarchy of the document.
  It conceptually corresponds to a table of contents in a printed work.

  For more information please see: [EPUB Navigation Document Definition](http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def)
  """

  alias BUPE.Builder.Templates

  def save(config, output) do
    content = Templates.nav_template(config)
    File.write!(output, content)
  end
end
