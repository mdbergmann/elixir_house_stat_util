defmodule HouseStatUtil.Router do
  use Plug.Router

  alias HouseStatUtil.TestController
  
  plug Plug.Logger
  
  plug Plug.Parsers,
    parsers: [:urlencoded],
    pass: ["text/*"]

  plug :match
  plug :dispatch

  get "/test" do
    {status, body} = TestController.get(conn.params)
    send_resp(conn, status, body)
  end

  match _ do
    send_resp(conn, 404, "Destination not found!")
  end
end
