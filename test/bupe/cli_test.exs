defmodule BUPE.CLITest do
  use ExUnit.Case, async: true

  alias BUPE.CLI

  import ExUnit.CaptureIO

  defp builder(_config, name, _opts) do
    {:ok, name}
  end

  test "minimum command-line options" do
    fun = fn ->
      CLI.main(["sample", "--page", "egg.xhtml"], &builder/3)
    end

    assert "EPUB successfully generated:\nsample.epub\n" == capture_io(fun)
  end

  test "at least one page is required" do
    fun = fn ->
      CLI.main(["sample"])
    end

    assert catch_exit(capture_io(fun)) == {:shutdown, 1}
  end

  test "too few arguments" do
    fun = fn ->
      CLI.main(["--page", "egg.xhtml"])
    end

    assert catch_exit(capture_io(fun)) == {:shutdown, 1}
  end

  test "version" do
    assert capture_io(fn ->
             CLI.main(["--version"])
           end) == "BUPE v#{BUPE.version()}\n"

    assert capture_io(fn ->
             CLI.main(["-v"])
           end) == "BUPE v#{BUPE.version()}\n"
  end

  test "help" do
    assert capture_io(fn ->
             CLI.main(["--help"])
           end) =~ "Usage:\n"

    assert capture_io(fn ->
             CLI.main(["-h"])
           end) =~ "Usage:\n"
  end
end
