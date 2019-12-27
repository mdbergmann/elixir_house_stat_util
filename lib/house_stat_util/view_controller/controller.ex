defmodule HouseStatUtil.ViewController.Controller do
  @callback get(params :: %{String.t() => any()}) :: {integer(), String.t()}
  @callback post(params :: %{String.t() => any()}) :: {integer(), String.t()}
end
