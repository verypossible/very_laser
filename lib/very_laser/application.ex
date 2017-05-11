defmodule VeryLaser.Application do
  use Application
  require Logger
  alias VeryLaser.Motor

  @motor1_pins [6, 13, 19, 26]
  @motor2_pins [12, 16, 20, 21]

  def start(_type, _args) do
    spawn fn -> @motor1_pins |> Motor.build() |> go() end
    spawn fn -> @motor2_pins |> Motor.build() |> go() end

    {:ok, self()}
  end

  defp go(pin_state) do
    next_pin_state = Enum.reduce(0..100, pin_state, fn (_, state) ->
      Logger.debug "Move!"
      Motor.move_cw(state)
    end)

    final_pin_state = Enum.reduce(0..100, next_pin_state, fn (_, state) ->
      Logger.debug "Move!"
      Motor.move_ccw(state)
    end)

    go(final_pin_state)
  end

  # # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # # for more information on OTP Applications
  # def start(_type, _args) do
  #   import Supervisor.Spec, warn: false

  #   # Define workers and child supervisors to be supervised
  #   children = [
  #     # worker(VeryLaser.Worker, [arg1, arg2, arg3]),
  #   ]

  #   # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
  #   # for other strategies and supported options
  #   opts = [strategy: :one_for_one, name: VeryLaser.Supervisor]
  #   Supervisor.start_link(children, opts)
  # end
end
