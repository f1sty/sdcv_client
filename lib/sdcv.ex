defmodule Sdcv do
  @moduledoc false
  require Logger

  def search(port, word) do
    Port.command(port, word <> "\n")
    process_message(:message, "") |> parse()
  end

  defp process_message(:message, message) do
    case String.ends_with?(message, "\nEnter word or phrase: ") do
      true ->
        process_message(:received, message)

      false ->
        receive do
          {_port, {:data, data}} ->
            process_message(:message, message <> data)

          other ->
            Logger.info("Unknown message: #{inspect(other)}")
        after
          5000 ->
            Logger.info("Timeout with message: #{inspect(message)}")
        end
    end
  end

  defp process_message(:received, message) do
    String.replace_trailing(message, "\nEnter word or phrase: ", "")
  end

  defp parse(definitions) when is_binary(definitions) do
    definitions
    |> String.split("-->")
    |> tl()
    |> Enum.chunk_every(2, 2, :discard)
    |> Enum.into(%{}, fn [k, v] -> {String.trim(k), v} end)
  end
end
