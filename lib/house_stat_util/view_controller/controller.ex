defmodule HouseStatUtil.ViewController.Controller do
  @callback get(params :: %{binary() => any()}) :: {integer(), binary()}
  @callback post(params :: %{binary() => any()}) :: {integer(), binary()}
end
