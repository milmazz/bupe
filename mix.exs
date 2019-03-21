defmodule BUPE.Mixfile do
  use Mix.Project

  @version "0.4.2-dev"

  def project do
    [
      app: :bupe,
      version: @version,
      name: "BUPE",
      source_url: "https://github.com/milmazz/bupe",
      homepage_url: "https://github.com/milmazz/bupe",
      elixir: "~> 1.8",
      description: description(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      docs: docs(),
      package: package(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix, :ex_unit, :xmerl],
        check_plt: true,
        flags: [:error_handling, :race_conditions, :underspecs]
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: []]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev},
      {:earmark, "~> 1.0", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.3", only: :dev, runtime: false},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    EPUB Generator and Parser
    """
  end

  defp docs do
    [extras: ["README.md"], main: "readme"]
  end

  defp package do
    [
      links: %{
        "GitHub" => "https://github.com/milmazz/bupe"
      },
      maintainers: ["Milton Mazzarri"],
      licenses: ["Apache 2.0"]
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
