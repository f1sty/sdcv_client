defmodule Sdcv.SdcvServer do
  @moduledoc false

  use GenServer
  require Logger

  def start_link(args \\ "sdcv -e") do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(cmd) do
    port = Port.open({:spawn, cmd}, [:binary])
    cache = :ets.new(:cache, [:public])

    {:ok, %{cache: cache, port: port}}
  end

  def search(word) do
    GenServer.call(__MODULE__, {:search, word})
  end

  def handle_call({:search, word}, _from, %{cache: cache, port: port} = state) do
    response =
      case :ets.lookup(cache, word) do
        [] ->
          case Sdcv.search(port, word) do
            definition when definition == %{} ->
              nil

            definition ->
              :ets.insert(cache, {word, definition})
              definition
          end

        [{^word, definition}] ->
          definition
      end

    {:reply, response, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
