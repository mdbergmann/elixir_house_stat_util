defmodule HouseStatUtil.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: HouseStatUtil.Router,
        options: [port: application_port()])
    ]

    opts = [strategy: :one_for_one, name: HouseStatUtil.Supervisor]
    Supervisor.start_link(children, opts)    
  end

  defp application_port do
    System.get_env()
    |> Map.get("PORT", "4001")
    |> String.to_integer()
  end
  
end
