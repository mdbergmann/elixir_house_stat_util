defmodule HouseStatUtil.Router do
  use Plug.Router

  alias HouseStatUtil.ViewController.TestController
  alias HouseStatUtil.ViewController.ReaderPageController
  
  plug Plug.Logger
  
  plug Plug.Parsers,
    parsers: [:urlencoded],
    pass: ["text/*"]

  plug :match
  plug :dispatch

  get "/" do
    {status, body} = ReaderPageController.get(conn.params)
    send_resp(conn, status, body)    
  end

  post "/submit_readers" do
    IO.inspect conn.params
    send_resp(conn, 200, "")
  end
  
  get "/test" do
    {status, body} = TestController.get(conn.params)
    send_resp(conn, status, body)
  end
  
  match _ do
    send_resp(conn, 404, "Destination not found!")
  end
end
