defmodule HouseStatUtil.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts HouseStatUtil.Router.init([])

  test "/test returns 'foo'" do
    conn = conn(:get, "/test")
    conn = HouseStatUtil.Router.call(conn, @opts)

    IO.inspect conn

    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "foo")
  end
end
