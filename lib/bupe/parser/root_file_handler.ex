defmodule BUPE.Parser.RootFileHandler do
  @behaviour Saxy.Handler

  @metadata ~w(
          contributor
          coverage
          creator
          date
          description
          format
          identifier
          language
          publisher
          relation
          rights
          source
          subject
          title
          type
      )

  def handle_event(:start_document, _prolog, %BUPE.Config{} = config) do
    IO.inspect("Start parsing document")
    {:ok, %{config: config}}
  end

  def handle_event(:end_document, _data, state) do
    IO.inspect("Finish parsing document")
    {:ok, state.config}
  end

  # START ELEMENT
  def handle_event(:start_element, {"package", attributes}, state) do
    attributes =
      attributes
      |> Enum.filter(&match?({k, _} when k in ~w|version unique-identifier|, &1))
      |> Map.new(fn
        {"version", v} -> {:version, v}
        {"unique-identifier", v} -> {:unique_identifier, v}
      end)

    {:ok, %{state | config: struct(state.config, attributes)}}
  end

  def handle_event(:start_element, {"dc:" <> metadata, _attributes}, state)
      when metadata in @metadata do
    {:ok, Map.put(state, :meta, metadata)}
  end

  def handle_event(:start_element, {"item", _attributes}, state) do
    {:ok, state}
  end

  # def handle_event(:start_element, {"spine", _attributes}, state) do
  #   {:ok, Map.put(state, :nav, [])}
  # end

  # def handle_event(:start_element, {"manifest", attributes}, state) do
  # end
  #
  def handle_event(:start_element, {"itemref", attributes}, state) do
    attributes =
      attributes
      |> Enum.filter(&match?({k, _} when k in ~w|idref|, &1))
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

    {:ok, Map.update(state, :nav, [attributes], &[attributes | &1])}
  end

  def handle_event(:start_element, {name, attributes}, state) do
    IO.inspect("Start parsing element #{name} with attributes #{inspect(attributes)}")
    {:ok, state}
  end

  # END ELEMENT
  def handle_event(:end_element, "spine", state) do
    {nav, state} = Map.pop(state, :nav)

    state =
      case nav do
        nil -> state
        nav when is_list(nav) -> %{state | config: struct(state.config, %{nav: nav})}
      end

    {:ok, state}
  end

  def handle_event(:end_element, name, state) do
    IO.inspect("Finish parsing element #{name}")
    {:ok, state}
  end

  # Characters
  def handle_event(:characters, chars, %{meta: current_key} = state)
      when current_key in @metadata do
    state = Map.delete(state, :meta)
    current_key = String.to_atom(current_key)
    {:ok, %{state | config: struct(state.config, %{current_key => chars})}}
  end

  def handle_event(:characters, chars, state) do
    IO.inspect("Receive characters #{chars}")
    {:ok, state}
  end

  # CDATA
  def handle_event(:cdata, cdata, state) do
    IO.inspect("Receive CData #{cdata}")
    {:ok, state}
  end
end
