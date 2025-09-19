defmodule BUPE.Parser.RootFileHandler do
  @moduledoc false
  @behaviour Saxy.Handler

  @dcterms ~w|identifier title language contributor coverage creator date description format publisher relation rights source subject type|
  @meta_dcterms ~w|modified source|
  @item_attributes ~w|id media-type href media-overlay properties fallback|
  @package_attributes ~w|dir id prefix xml:lang version unique-identifier|
  @itemref_attributes ~w|id idref linear properties|
  @meta_attributes ~w|dir id property refines scheme xml:lang|
  @spine_attributes ~w|id toc|

  def handle_event(:start_document, _prolog, %BUPE.Config{} = config),
    do: {:ok, %{config: config}}

  def handle_event(:end_document, _data, state), do: {:ok, state.config}

  # START ELEMENT
  def handle_event(:start_element, {"package", attributes}, state) do
    attributes =
      attributes
      |> Enum.filter(&match?({k, _} when k in @package_attributes, &1))
      |> Map.new(fn
        {"xml:lang", v} -> {:language, v}
        {"unique-identifier", v} -> {:unique_identifier, v}
        {k, v} -> {String.to_atom(k), v}
      end)

    {:ok, %{state | config: struct(state.config, attributes)}}
  end

  def handle_event(:start_element, {element, _attributes}, state)
      when element in ~w(metadata manifest), do: {:ok, Map.put(state, :parent, element)}

  def handle_event(:start_element, {"spine", attributes}, state) do
    config =
      if state.config.version == "2.0" do
        attributes =
          attributes
          |> Enum.filter(&match?({k, _} when k in @spine_attributes, &1))
          |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

        toc_id = Map.fetch!(attributes, :toc)
        toc_attributes = Enum.find(state.legacy_ncx, &(&1.id == toc_id))
        struct(state.config, %{toc: [toc_attributes]})
      else
        state.config
      end

    {:ok, Map.merge(state, %{config: config, parent: "spine"})}
  end

  def handle_event(
        :start_element,
        {"dc:" <> dcterm, _attributes},
        %{parent: "metadata"} = state
      )
      when dcterm in @dcterms, do: {:ok, Map.put(state, :dcterm, dcterm)}

  def handle_event(:start_element, {"meta", attributes}, %{parent: "metadata"} = state) do
    attributes =
      attributes
      |> Enum.filter(&match?({k, _} when k in @meta_attributes, &1))
      |> Map.new(fn
        {"xml:lang", v} -> {:language, v}
        {k, v} -> {String.to_atom(k), v}
      end)

    state =
      case Map.get(attributes, :property) do
        "dcterms:" <> dcterm when dcterm in @meta_dcterms ->
          Map.put(state, :dcterm, dcterm)

        _ ->
          state
      end

    {:ok, state}
  end

  def handle_event(:start_element, {"item", attributes}, %{parent: "manifest"} = state) do
    attributes =
      attributes
      |> Enum.filter(&match?({k, _} when k in @item_attributes, &1))
      |> Map.new(fn
        {"media-type", v} -> {:media_type, v}
        {"media-overlay", v} -> {:media_overlay, v}
        {k, v} -> {String.to_atom(k), v}
      end)

    properties = attributes |> Map.get(:properties, "") |> String.split()

    config =
      if state.config.version == "3.0" and "nav" in properties do
        struct(state.config, %{toc: [attributes]})
      else
        state.config
      end

    state =
      state
      |> Map.update(:items, [attributes], &[attributes | &1])
      |> Map.put(:config, config)

    {:ok, state}
  end

  def handle_event(:start_element, {"itemref", attributes}, %{parent: "spine"} = state) do
    attributes =
      attributes
      |> Enum.filter(&match?({k, _} when k in @itemref_attributes, &1))
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

    {:ok, Map.update(state, :nav, [attributes], &[attributes | &1])}
  end

  # END ELEMENT
  def handle_event(:end_element, "spine", %{parent: "spine"} = state) do
    {nav, state} =
      state
      |> Map.delete(:parent)
      |> Map.pop(:nav)

    nav = nav |> List.wrap() |> Enum.reverse()

    {:ok, %{state | config: struct(state.config, %{nav: nav})}}
  end

  def handle_event(:end_element, "manifest", %{parent: "manifest"} = state) do
    {items, state} =
      state
      |> Map.delete(:parent)
      |> Map.pop(:items)

    items =
      items
      |> List.wrap()
      |> Enum.group_by(& &1.media_type)

    state =
      if Enum.any?(items) do
        publication_resources =
          Map.new(
            [
              images: ["image/jpeg", "image/gif", "image/png", "image/svg+xml", "image/webp"],
              scripts: ["application/javascript", "application/ecmascript", "text/javascript"],
              styles: ["text/css"],
              pages: ["application/xhtml+xml"],
              audio: ["audio/mpeg", "audio/mp4", "audio/ogg; codecs=opus"],
              fonts: [
                "font/ttf",
                "font/otf",
                "font/woff",
                "font/woff2",
                "application/font-sfnt",
                "application/font-woff",
                "application/vnd.ms-opentype"
              ]
            ],
            fn {k, media_types} ->
              publication_resources(k, media_types, items)
            end
          )

        legacy_ncx = Map.get(items, "application/x-dtbncx+xml", [])
        config = struct(state.config, publication_resources)
        Map.merge(state, %{config: config, legacy_ncx: legacy_ncx})
      else
        state
      end

    {:ok, state}
  end

  def handle_event(:end_element, "metadata", %{parent: "metadata"} = state) do
    {:ok, Map.delete(state, :parent)}
  end

  # Characters
  def handle_event(:characters, chars, %{dcterm: dcterm, parent: "metadata"} = state)
      when dcterm in @dcterms or dcterm in @meta_dcterms do
    state = Map.delete(state, :dcterm)
    current_key = String.to_atom(dcterm)
    {:ok, %{state | config: struct(state.config, %{current_key => chars})}}
  end

  def handle_event(_, _, state) do
    {:ok, state}
  end

  ## Helpers
  defp publication_resources(category, media_types, items) do
    resources =
      Enum.flat_map(media_types, fn media_type ->
        Map.get(items, media_type, [])
      end)

    {category, resources}
  end
end
