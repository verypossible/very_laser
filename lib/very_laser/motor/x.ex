defmodule VeryLaser.Motor.X do
  alias VeryLaser.Motor.Server

  @pins [21, 20, 16, 12]
  @timeout 300_000
  @offset 61
  @range 39

  def start_link do
    GenServer.start_link(Server, {@pins, @offset, @rangei}, name: __MODULE__)
  end

  @spec step(integer) :: :ok | {:error, term}
  def step(n_steps) when is_integer(n_steps) do
    GenServer.call(__MODULE__, {:step, n_steps}, @timeout)
  end

  @spec to_step_position(non_neg_integer) :: :ok | {:error, term}
  def to_step_position(position) when is_integer(position) and position >= 0 do
    GenServer.call(__MODULE__, {:to_step_position, position}, @timeout)
  end

  @spec get_position :: non_neg_integer
  def get_position do
    GenServer.call(__MODULE__, :get_position, @timeout)
  end
end
