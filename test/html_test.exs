defmodule HouseStatUtil.HTMLTest do
  use ExUnit.Case

  import HouseStatUtil.HTML
  
  test "input element" do
    input_elem = input(id: "some-id", name: "some-name", value: "some-value")
    |> generate_string

    IO.inspect input_elem

    assert String.starts_with?(input_elem, "<input")
    assert String.contains?(input_elem, "id=\"some-id\"")
    assert String.contains?(input_elem, "name=\"some-name\"")
    assert String.contains?(input_elem, "value=\"some-value\"")
  end
  
end
