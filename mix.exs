defmodule ApiServer.Mixfile do
  use Mix.Project

  def project do
    [app: :api_server,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {ApiServer, []},
      applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                     :httpoison, :gproc, :econfig, :yaml_elixir]
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.0.2"},
     {:phoenix_html, "~> 2.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:plug, "~> 1.0"},
     {:poison, "~> 1.5.0"},
     {:corsica, "~> 0.3"},
     {:httpoison, "~> 0.7.2"},
     {:csv, "~> 1.1.0"},
     { :epgsql, github: "epgsql/epgsql"},
     { :poolboy, github: "devinus/poolboy" },
     { :econfig, github: "benoitc/econfig" },
     { :yaml_elixir, github: "KamilLelonek/yaml-elixir" },
     { :yamerl, github: "yakaz/yamerl" },
     { :dogma,  github: "lpil/dogma", only: :dev}
  ]
  end
end
