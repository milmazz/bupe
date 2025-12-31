defmodule BUPE.Item do
  @moduledoc """
  The [Item][item] element definition.

  Each **Item** element represents a [Publication Resource][pub-resource].

  [item]: http://www.idpf.org/epub/31/spec/epub-packages.html#sec-manifest-elem
  [pub-resource]: (http://www.idpf.org/epub/31/spec/epub-spec.html#gloss-publication-resource-cmt-or-foreign).

  NOTE: The key `content` in the following struct is not part of the EPUB spec, but,
  we use that key internally to hold the content of the file that's associated
  with the Item for parsing purposes.
  """
  @type t :: %__MODULE__{
          duration: nil | String.t(),
          fallback: nil | String.t(),
          href: String.t(),
          id: nil | String.t(),
          media_overlay: nil | String.t(),
          media_type: nil | String.t(),
          properties: nil | String.t(),
          description: nil | String.t(),
          content: nil | String.t()
        }

  @enforce_keys [:href]
  defstruct [
    :duration,
    :fallback,
    :href,
    :id,
    :media_overlay,
    :media_type,
    :description,
    :properties,
    :content
  ]

  @deprecated "Use normalize/1 instead"
  def from_string(path) when is_binary(path), do: normalize(%__MODULE__{href: path})

  @doc """
  Normalize the given `BUPE.Item` struct.

  ## Examples

      iex> BUPE.Item.normalize(%BUPE.Item{
      ...>   id: "ode-to-bacon",
      ...>   href: "book/bacon.xhtml",
      ...>   description: "Ode to Bacon"
      ...> })
      %BUPE.Item{
        description: "Ode to Bacon",
        duration: nil,
        fallback: nil,
        href: "book/bacon.xhtml",
        id: "ode-to-bacon",
        media_overlay: nil,
        media_type: "application/xhtml+xml",
        properties: nil
      }

  """
  @spec normalize(t() | binary()) :: t()
  def normalize(path) when is_binary(path), do: normalize(%__MODULE__{href: path})

  def normalize(%__MODULE__{} = item) do
    %{id: id, media_type: media_type, href: href, description: description} = item

    id = if id, do: id, else: "i-#{BUPE.UUID.uuid4()}"
    description = if description, do: description, else: Path.basename(href, Path.extname(href))

    media_type =
      if media_type do
        media_type
      else
        BUPE.MediaType.from_path(href)
      end

    %{item | id: id, media_type: media_type, description: description}
  end
end
