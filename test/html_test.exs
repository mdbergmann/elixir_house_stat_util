defmodule HouseStatUtil.HTMLTest do
  use ExUnit.Case

  import HouseStatUtil.HTML
  
  test "single element with attributes" do
    elem = ht :input, id: "some-id", name: "some-name", value: "some-value" do end
    |> render_to_string

    IO.inspect elem

    assert String.starts_with?(elem, "<input")
    assert String.contains?(elem, ~s(id="some-id"))
    assert String.contains?(elem, ~s(name="some-name"))
    assert String.contains?(elem, ~s(value="some-value"))
    assert String.ends_with?(elem, "/>")
  end

  test "multiple sub elements - container" do
    html_elem = ht :html, class: "foo" do [
      ht :head do end,
      ht :body, class: "bar" do end
    ] end
    |> render_to_string

    IO.inspect html_elem

    assert String.ends_with?(html_elem, 
      "<html class=\"foo\"><head></head><body class=\"bar\"></body></html>")
  end
  
end
