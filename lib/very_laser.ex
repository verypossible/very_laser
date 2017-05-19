defmodule VeryLaser do
  alias VeryLaser.Motor

  @timeout 300_000

  def run() do
    Motor.X.step(50)
    Motor.X.step(-50)

    Motor.Y.step(50)
    Motor.Y.step(-50)
  end

  def to_step_position(x_position, y_position) do
    x_task = Task.async(fn -> Motor.X.to_step_position(x_position) end)
    y_task = Task.async(fn -> Motor.Y.to_step_position(y_position) end)

    Task.await(x_task, @timeout)
    Task.await(y_task, @timeout)
  end

  def step(x_step, y_step) do
    x_task = Task.async(fn -> Motor.X.step(x_step) end)
    y_task = Task.async(fn -> Motor.Y.step(y_step) end)

    Task.await(x_task, @timeout)
    Task.await(y_task, @timeout)
  end

  def get_position, do: {Motor.X.get_position(), Motor.Y.get_position()}
end
