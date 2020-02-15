defmodule HouseStatUtil.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_house_stat_util,
      version: "0.2.1",
      elixir: "~> 1.9",
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HouseStatUtil.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.1.0"},
      {:eml, git: "https://github.com/zambal/eml.git"},
      {:httpoison, "~> 1.6.2"},
      {:gettext, "~> 0.17.1"},
      {:mock, "~> 0.3.4", only: :test}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
