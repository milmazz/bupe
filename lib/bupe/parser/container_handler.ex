defmodule BUPE.Parser.ContainerHandler do
  @behaviour Saxy.Handler

  def handle_event(:start_element, {"rootfile", attributes}, _state) do
    full_path = Enum.find_value(attributes, fn {k, v} -> if k == "full-path", do: v end)
    {:stop, full_path}
  end

  def handle_event(_, _, state), do: {:ok, state}
end
