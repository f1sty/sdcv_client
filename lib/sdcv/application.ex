defmodule Sdcv.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Sdcv.SdcvServer, "sdcv -e"}
    ]

    opts = [strategy: :one_for_one, name: Sdcv.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
