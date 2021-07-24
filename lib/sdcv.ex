defmodule Sdcv do
  @moduledoc false

  @cmd "sdcv"

  def search(word) do
    case System.cmd(@cmd, ["-ne", word]) do
      {definition, 0} -> definition
      _ -> nil
    end
    |> parse()
  end

  defp parse(nil), do: %{}

  defp parse(definitions) do
    definitions
    |> String.split("-->")
    |> tl()
    |> Enum.chunk_every(2, 2, :discard)
    |> Enum.into(%{}, fn [k, v] -> {String.trim(k), v} end)
  end
end
