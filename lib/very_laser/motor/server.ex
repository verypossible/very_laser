defmodule VeryLaser.Motor.Server do
  use GenServer

  @type t::%__MODULE__{position: non_neg_integer, pin_state: non_neg_integer, pins: {pid, pid, pid, pid}, offset: non_neg_integer, range: non_neg_integer}
  defstruct position: 0, pin_state: 0, pins: nil, offset: 0, range: 0

  @steps_to_zero 200
  @pin_states {{0, 0, 0, 1},
              {0, 0, 1, 1},
              {0, 0, 1, 0},
              {0, 1, 1, 0},
              {0, 1, 0, 0},
              {1, 1, 0, 0},
              {1, 0, 0, 0},
              {1, 0, 0, 1}}

  alias ElixirALE.GPIO

  # Callbacks
  def init({pin_numbers, offset, range}) do
    state = %__MODULE__{
      pins: build_pins(pin_numbers),
      pin_state: 0,
      position: 0,
      offset: offset,
      range: range,
    }

    zero(state)
    {:ok, state}
  end

  defp zero(state) do
    Enum.reduce(1..@steps_to_zero, state, fn _, acc -> move_cw(acc) end)
    step(state, state.offset)
  end

  @spec step(t, integer) :: {:ok, t} | {:error, :out_of_bounds}
  defp step(state, 0), do: {:ok, state}
  defp step(%{position: position}, differential) when position + differential < 0 do
    {:error, :out_of_bounds}
  end
  defp step(%{range: range, position: position}, differential) when position + differential > range do
    {:error, :out_of_bounds}
  end
  defp step(state, differential) when differential > 0 do
    new_state = Enum.reduce(1..differential, state, fn _, acc -> move_ccw(acc) end)
    {:ok, new_state}
  end
  defp step(state, differential) when differential < 0 do
    new_state = Enum.reduce(1..-differential, state, fn _, acc -> move_cw(acc) end)
    {:ok, new_state}
  end

  @spec to_step_position(t, non_neg_integer) :: {:ok, t} | {:error, :out_of_bounds}
  defp to_step_position(state, new_position) when is_integer(new_position) and new_position >= 0 do
    %{position: curr_pos} = state
    differential = new_position - curr_pos

    step(state, differential)
  end

  def handle_call({:step, n_steps}, _from, state) do
    case step(state, n_steps) do
      {:ok, new_state} -> {:reply, :ok, new_state}
      reply -> {:reply, reply, state}
    end
  end
  def handle_call({:to_step_position, position}, _from, state) do
    case to_step_position(state, position) do
      {:ok, new_state} -> {:reply, :ok, new_state}
      reply -> {:reply, reply, state}
    end
  end
  def handle_call(:get_position, _from, state) do
    {:reply, state.position, state}
  end

  defp build_pins(pin_numbers) do
    pin_numbers
    |> Enum.map(&output_pin/1)
    |> List.to_tuple()
  end

  defp output_pin(pin_number) do
    pin_number
    |> GPIO.start_link(:output)
    |> elem(1)
  end

  defp move_cw(state), do: move(state, &decrement_step_position/1)
  defp decrement_step_position(state), do: {state.pin_state-1, state.position-1}

  defp move_ccw(state), do: move(state, &increment_step_position/1)
  defp increment_step_position(state), do: {state.pin_state+1, state.position+1}

  @spec move(t, (t -> {integer, integer})) :: t
  defp move(state, change_fn) do
    {changed_state, changed_pos} = change_fn.(state)
    next_pin = Integer.mod(changed_state, 8)
    next_state = @pin_states |> elem(next_pin)

    for pin_num <- 0..3 do
      GPIO.write(get_pin(state, pin_num), next_state |> elem(pin_num))
    end
    :timer.sleep(10)

    %{state | pin_state: next_pin, position: changed_pos}
  end

  defp get_pin(state, number) do
    state
    |> Map.get(:pins)
    |> elem(number)
  end
end
