defmodule HouseStatUtil.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HouseStatUtil.Router
  
  @opts HouseStatUtil.Router.init([])

  test "get on '/'" do
    conn = :get
    |> conn("/")
    |> Router.call(@opts)

    IO.inspect conn

    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "Submit values to openHAB")
  end

  test "post on /submit_readers" do
    conn = :post
    |> conn("/submit_readers")
    |> Router.call(@opts)

    IO.inspect conn

    assert conn.state == :sent
    assert conn.status == 200
  end
end
