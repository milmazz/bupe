defmodule BUPE.Mixfile do
  use Mix.Project

  def project do
    [app: :bupe,
     version: "0.1.0",
     name: "BUPE",
     source_url: "https://github.com/milmazz/bupe",
     homepage_url: "https://github.com/milmazz/bupe",
     elixir: "~> 1.3",
     description: description(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     docs: docs(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.13", only: :dev},
      {:earmark, "~> 1.0", only: :dev}
    ]
  end

  defp description do
    """
    EPUB Generator and Parser
    """
  end

  defp docs do
    [extras: ["README.md"], main: "README"]
  end

  defp package do
    [
      links: %{
        "GitHub" => "https://github.com/milmazz/bupe"
      },
      maintainers: ["milmazz@gmail.com"],
      licenses: []
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
