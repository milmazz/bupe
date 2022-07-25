defmodule BUPE.Mixfile do
  use Mix.Project

  @source_url "https://github.com/milmazz/bupe"
  @version "0.6.0"

  def project do
    [
      app: :bupe,
      version: @version,
      name: "BUPE",
      source_url: @source_url,
      homepage_url: @source_url,
      elixir: "~> 1.3",
      description: description(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      docs: docs(),
      package: package(),
      deps: deps(),
      dialyzer: dialyzer(),
      escript: escript()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [], extra_applications: [:xmerl, :eex, :crypto]]
  end

  def dialyzer do
    [
      plt_add_apps: [:mix, :ex_unit, :xmerl],
      check_plt: true,
      flags: [:error_handling, :race_conditions, :underspecs]
    ]
  end

  def escript do
    [main_module: BUPE.CLI]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev},
      {:dialyxir, "~> 1.2.0", only: :dev, runtime: false},
      {:credo, "~> 1.6.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    EPUB Generator and Parser
    """
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "CODE_OF_CONDUCT.md": [title: "Code of Conduct"],
        "CONTRIBUTING.md": [title: "Contributing"],
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme"
    ]
  end

  defp package do
    [
      links: %{
        "Changelog" => "https://hexdocs.pm/bupe/changelog.html",
        "GitHub" => @source_url
      },
      maintainers: ["Milton Mazzarri"],
      licenses: ["Apache-2.0"]
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
