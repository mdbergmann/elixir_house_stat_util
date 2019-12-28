defmodule HouseStatUtil.ViewController.ReaderPageControllerTest do
  use ExUnit.Case

  alias HouseStatUtil.ViewController.ReaderPageController
  
  test "handle GET" do
    assert {200, body} = ReaderPageController.get(%{})
  end
  
end
