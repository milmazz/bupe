defmodule BUPE.Item do
  @moduledoc """
  The [Item][item] element definition.

  Each **Item** element represents a [Publication Resource][pub-resource].

  [item]: http://www.idpf.org/epub/31/spec/epub-packages.html#sec-manifest-elem
  [pub-resource]: (http://www.idpf.org/epub/31/spec/epub-spec.html#gloss-publication-resource-cmt-or-foreign).
  """
  alias BUPE.Util

  @type t :: %__MODULE__{
          duration: nil | String.t(),
          fallback: nil | String.t(),
          href: String.t(),
          id: nil | String.t(),
          media_overlay: nil | String.t(),
          media_type: nil | String.t(),
          properties: nil | String.t(),
          description: nil | String.t()
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
    :properties
  ]

  @spec from_string(binary()) :: t()
  def from_string(path) when is_binary(path) do
    id = "i-#{Util.uuid4()}"
    description = Path.basename(path, Path.extname(path))
    media_type = Util.media_type_from_path(path)

    %__MODULE__{
      id: id,
      description: description,
      href: path,
      media_type: media_type
    }
  end

  @spec normalize(t()) :: t()
  def normalize(%__MODULE__{id: id, media_type: media_type, href: href} = item) do
    id = if id, do: id, else: "i-#{Util.uuid4()}"

    media_type =
      if media_type do
        media_type
      else
        Util.media_type_from_path(href)
      end

    %{item | id: id, media_type: media_type}
  end
end
