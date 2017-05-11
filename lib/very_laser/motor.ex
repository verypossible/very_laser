defmodule VeryLaser.Motor do
  defstruct current_pin: 0, pins: nil

  alias ElixirALE.GPIO

  def build(pin_numbers, starting_pin\\0) do
    %__MODULE__{
      pins: build_pins(pin_numbers),
      current_pin: starting_pin,
    }
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

  def move_cw(pin_state) do
    next_pin = Integer.mod(pin_state.current_pin + 1, 4)
    GPIO.write(get_pin(pin_state, next_pin), 1)
    :timer.sleep(50)
    GPIO.write(get_pin(pin_state, pin_state.current_pin), 0)
    :timer.sleep(50)

    %{pin_state | current_pin: next_pin}
  end

  def move_ccw(pin_state) do
    next_pin = Integer.mod(pin_state.current_pin - 1, 4)
    GPIO.write(get_pin(pin_state, next_pin), 1)
    :timer.sleep(50)
    GPIO.write(get_pin(pin_state, pin_state.current_pin), 0)
    :timer.sleep(50)

    %{pin_state | current_pin: next_pin}
  end

  defp get_pin(pin_state, number) do
    pin_state
    |> Map.get(:pins)
    |> elem(number)
  end
end
