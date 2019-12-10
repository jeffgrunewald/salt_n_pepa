defmodule SaltNPepa.MixProject do
  use Mix.Project

  def project do
    [
      app: :salt_n_pepa,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:gen_stage, "~> 0.14.0"}
    ]
  end
end
