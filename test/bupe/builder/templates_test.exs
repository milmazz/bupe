defmodule BUPE.Builder.TemplatesTest do
  use BUPETest.Case, async: true

  alias BUPE.Builder.Templates

  test "nav template" do
    config = config(%{})

    content = Templates.nav_template(config)

    assert content =~ ~r{<li><a href="content/bacon.xhtml">1. Ode to Bacon</a></li>}
    assert content =~ ~r{<li><a href="content/ham.xhtml">2. Ode to Ham</a></li>}
    assert content =~ ~r{<li><a href="content/egg.xhtml">3. Ode to Egg</a></li>}
  end

  test "toc template" do
    config = config(%{})

    content = Templates.ncx_template(config)

    assert content =~ ~r{<navPoint id="ode-to-bacon" playOrder="2">}
    assert content =~ ~r{<navPoint id="ode-to-ham" playOrder="3">}
    assert content =~ ~r{<navPoint id="ode-to-egg" playOrder="4">}

    assert content =~ ~r{<content src="content/bacon.xhtml" />}
    assert content =~ ~r{<content src="content/ham.xhtml" />}
  end

  test "cover template" do
    config = config(%{})

    content = Templates.title_template(config)

    assert content =~ ~r{<h1>Sample</h1>}
    assert content =~ ~r{<title>Sample</title>}
  end

  test "package template" do
    config = config(%{})

    content = Templates.content_template(config)

    assert content =~ ~r{<dc:title>Sample</dc:title>}
    assert content =~ ~r{<dc:language>en</dc:language>}
    assert content =~ ~r{<meta property="dcterms:modified">2016-06-23T06:00:00Z</meta>}
  end
end
