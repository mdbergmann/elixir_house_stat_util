defmodule HouseStatUtil.Router do
  use Plug.Router

  alias HouseStatUtil.ViewController.ReaderPageController
  alias HouseStatUtil.ViewController.ReaderSubmitPageController
  
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
    {status, body} = ReaderSubmitPageController.post(conn.params)
    send_resp(conn, status, body)
  end
  
  match _ do
    send_resp(conn, 404, "Destination not found!")
  end
end
