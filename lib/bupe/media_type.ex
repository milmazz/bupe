defmodule BUPE.MediaType do
  @moduledoc false

  @spec from_path(Path.t()) :: nil | String.t()
  def from_path(path) when is_binary(path) do
    path
    |> Path.extname()
    |> String.downcase()
    |> media_type()
  end

  @media_types %{
    "css" => "text/css",
    "eot" => "application/vnd.ms-opentype",
    "gif" => "image/gif",
    "html" => "application/xhtml+xml",
    "jpeg" => "image/jpeg",
    "jpg" => "image/jpeg",
    "js" => "text/javascript",
    "mp3" => "audio/mpeg",
    "mp4" => "video/mp4",
    "ncx" => "application/x-dtbncx+xml",
    "opf" => "application/oebps-package+xml",
    "otf" => "application/vnd.ms-opentype",
    "png" => "image/png",
    "svg" => "image/svg+xml",
    "ttc" => "application/vnd.ms-opentype",
    "ttf" => "application/vnd.ms-opentype",
    "woff" => "application/font-woff",
    "xhtml" => "application/xhtml+xml"
  }

  for {extension, media} <- @media_types do
    defp media_type("." <> unquote(extension)) do
      unquote(media)
    end
  end

  defp media_type(_), do: nil
end
