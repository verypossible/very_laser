defmodule VeryLaser.Mixfile do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"
  Mix.shell.info([:green, """
  Env
    MIX_TARGET:   #{@target}
    MIX_ENV:      #{Mix.env}
  """, :reset])
  def project do
    [
      app: :very_laser,
      version: "0.1.0",
      elixir: "~> 1.4.0",
      target: @target,
      archives: [nerves_bootstrap: "~> 0.3.0"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      dialyzer: [
        flags: [:error_handling, :race_conditions, :underspecs],
        plt_add_deps: :transitive,
      ],
      aliases: aliases(@target),
      deps: deps(),
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application, do: application(@target)

  # Specify target specific application configurations
  # It is common that the application start function will start and supervise
  # applications which could cause the host to fail. Because of this, we only
  # invoke VeryLaser.start/2 when running on a target.
  def application("host") do
    [extra_applications: [:logger]]
  end
  def application(_target) do
    [
      mod: {VeryLaser.Application, []},
      extra_applications: [:logger],
    ]
  end

  def deps do
    [
      {:nerves, "~> 0.5.0", runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
    ] ++
    deps(@target)
  end

  def deps("host"), do: []
  def deps(target) do
    [
      {:nerves_runtime, "~> 0.1.0"},
      {:"nerves_system_#{target}", "~> 0.11.0", runtime: false},
      {:elixir_ale, "~> 1.0"},
    ]
  end

  # We do not invoke the Nerves Env when running on the Host
  def aliases("host"), do: []
  def aliases(_target) do
    [
      "deps.precompile": ["nerves.precompile", "deps.precompile"],
      "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"],
    ]
  end

end
