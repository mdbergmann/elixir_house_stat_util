defmodule HouseStatUtil.ViewController.ReaderPageControllerTest do
  use ExUnit.Case

  alias HouseStatUtil.ViewController.ReaderPageController
  
  test "handle GET" do
    assert {200, _} = ReaderPageController.get(%{})
  end

  test "handle POST returns error" do
    assert {400, _} = ReaderPageController.post(%{})
  end
end
