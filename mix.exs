defmodule Jockey.MixProject do
  use Mix.Project

  def project do
    [
      app: :jockey,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description()
      deps: deps()
    ] ++ package()
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Access and fetching of resources according to user permissions by decorators
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Sebastián González"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sebastialonso/jockey"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decorator, "~> 1.3.0"},
      {:plug_cowboy, "~> 2.0.1"},
      {:tesla, "~> 1.2.1"},
      {:mock, "~> 0.3.0", only: :test}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
