defmodule PhxExRay.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_ex_ray,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Wrapper around ex_ray for OpenTrace in Elixir Phoenix",
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [# These are the default files included in the package
     files: ["lib", "mix.exs", "README*"],
     maintainers: ["sashman90@gmail.com"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/sashman/phx_ex_ray"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:ex_ray , "~> 0.1"}
    ]
  end
end
