defmodule VeryLaser.Application do
  use Application
  require Logger
  alias VeryLaser.Motor

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Motor.X, []),
      worker(Motor.Y, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VeryLaser.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
