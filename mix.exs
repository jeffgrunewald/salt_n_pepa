defmodule SaltNPepa.MixProject do
  use Mix.Project

  def project do
    [
      app: :salt_n_pepa,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      source_url: "https://github.com/jeffgrunewald/salt_n_pepa",
      dialyzer: [plt_file: {:no_warn, ".plt/dialyzer.plt"}]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.7", only: :dev, runtime: false},
      {:gen_stage, "~> 0.14.0"},
      {:jason, "~> 1.1", only: :test},
      {:ex_doc, "~> 0.21.0", only: :dev}
    ]
  end

  defp description(), do: "An Elixir library for creating data ingestion push gateways."

  defp elixirc_paths(env) when env in [:test, :integration], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package() do
    [
      maintainers: ["jeffgrunewald"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/jeffgrunewald/salt_n_pepa"}
    ]
  end

  defp docs() do
    [
      main: "readme",
      source_url: "https://github.com/jeffgrunewald/salt_n_pepa",
      extras: [
        "README.md"
      ]
    ]
  end
end
