defmodule BUPE.EPUBCheckTest do
  use BUPETest.Case, async: true

  # Validates generated EPUBs with the official EPUBCheck tool, covering
  # every combination the builder can produce: both EPUB versions, with and
  # without a cover page, and with and without a logo.
  #
  # Excluded from the default run because it needs Java and the EPUBCheck
  # jar. Run it with:
  #
  #     EPUBCHECK_JAR=path/to/epubcheck.jar mix test --only epubcheck
  #
  @moduletag :epubcheck

  # The 30/ fixture pages use the HTML5 doctype required by EPUB 3, while the
  # 20/ pages use the XHTML 1.1 doctype that EPUB 2.0.1 expects, so each
  # version is paired with pages it can legally carry.
  defp config("3.0"), do: config()

  defp config("2.0") do
    pages =
      "/20/*.xhtml"
      |> fixtures_dir()
      |> Path.wildcard()

    %{config() | version: "2.0", pages: pages}
  end

  @tag :tmp_dir
  @tag timeout: 120_000
  test "generated EPUBs pass EPUBCheck", %{tmp_dir: tmp_dir} do
    jar = System.fetch_env!("EPUBCHECK_JAR")
    logo = fixtures_dir("logo.png")

    samples = [
      {"v30.epub", config("3.0")},
      {"v30-logo.epub", %{config("3.0") | logo: logo}},
      {"v30-no-cover.epub", %{config("3.0") | cover: false}},
      {"v20.epub", config("2.0")},
      {"v20-logo.epub", %{config("2.0") | logo: logo}},
      {"v20-no-cover.epub", %{config("2.0") | cover: false}}
    ]

    for {name, config} <- samples do
      output = Path.join(tmp_dir, name)
      assert {:ok, ^output} = BUPE.build(config, output)

      {report, status} = System.cmd("java", ["-jar", jar, output], stderr_to_stdout: true)

      assert status == 0, "EPUBCheck reported problems for #{name}:\n#{report}"
    end
  end
end
