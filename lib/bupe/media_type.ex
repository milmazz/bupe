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
    "gif" => "image/gif",
    "jpg" => "image/jpeg",
    "jpeg" => "image/jpeg",
    "png" => "image/png",
    "svg" => "image/svg+xml",
    "xhtml" => "application/xhtml+xml",
    "html" => "application/xhtml+xml",
    "ncx" => "application/x-dtbncx+xml",
    "otf" => "application/vnd.ms-opentype",
    "ttf" => "application/vnd.ms-opentype",
    "ttc" => "application/vnd.ms-opentype",
    "eot" => "application/vnd.ms-opentype",
    "woff" => "application/font-woff",
    "opf" => "application/oebps-package+xml",
    "mp3" => "audio/mpeg",
    "mp4" => "video/mp4",
    "css" => "text/css",
    "js" => "text/javascript"
  }

  for {extension, media} <- @media_types do
    defp media_type("." <> unquote(extension)) do
      unquote(media)
    end
  end

  defp media_type(_), do: nil
end
