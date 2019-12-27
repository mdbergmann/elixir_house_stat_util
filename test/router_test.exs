defmodule HouseStatUtil.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HouseStatUtil.Router
  
  @opts HouseStatUtil.Router.init([])

  test "/test returns 200, 'foo'" do
    conn = :get
    |> conn("/test")
    |> Router.call(@opts)

    IO.inspect conn

    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "foo")
  end

  test "get on '/'" do
    conn = :get
    |> conn("/")
    |> Router.call(@opts)

    IO.inspect conn

    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "Submit values to openHAB")
  end
end
