defmodule Sdcv.SdcvServer do
  @moduledoc false

  use GenServer
  require Logger

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    cache = :ets.new(:cache, [:public])
    {:ok, %{cache: cache}}
  end

  def search(word) do
    GenServer.call(__MODULE__, {:search, word})
  end

  def handle_call({:search, word}, _from, %{cache: cache} = state) do
    response =
      case :ets.lookup(cache, word) do
        [] ->
          case Sdcv.search(word) do
            nil ->
              "no definition"

            definition ->
              :ets.insert(cache, {word, definition})
              definition
          end

        [{^word, definition}] ->
          Logger.info("hit cache with word '#{word}'")
          definition
      end

    {:reply, response, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
