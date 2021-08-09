defmodule ExBitset.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_bitset,
      version: "1.1.1",
      elixir: "~> 1.12",

      description: "Bitsets implementation",
      package: package(),
      docs: docs(),

      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:benchfella, "~> 0.3.0", only: :dev},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit],
      flags: [
        :race_conditions,
        :no_opaque,
        :error_handling,
        :underspecs,
        :unknown,
        :unmatched_returns
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Sebastian Borrazas"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sborrazas/ex_bitset"}
    ]
  end

  defp docs do
    [
      main: "ExBitset",
      source_url: "https://github.com/sborrazas/ex_bitset",
      extras: ["README.md"]
    ]
  end
end
