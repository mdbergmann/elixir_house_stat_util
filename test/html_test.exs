defmodule HouseStatUtil.HTMLTest do
  use ExUnit.Case

  import HouseStatUtil.HTML
  
  test "input element - primitive" do
    input_elem = input(id: "some-id", name: "some-name", value: "some-value")
    |> render_to_string

    IO.inspect input_elem

    assert String.starts_with?(input_elem, "<input")
    assert String.contains?(input_elem, ~s(id="some-id"))
    assert String.contains?(input_elem, ~s(name="some-name"))
    assert String.contains?(input_elem, ~s(value="some-value"))
  end

  test "html element - container" do
    html_elem = html(
      [
        htag(:head),
        htag(:body)
      ],
      class: "foo"
    )
    |> render_to_string

    IO.inspect html_elem

    assert String.ends_with?(html_elem, 
      "<html class=\"foo\"><head></head><body></body></html>")
  end
  
  test "head element - container" do
    head_elem = head(
      htag(:title, "Foo")
    )
    |> render_to_string

    IO.inspect head_elem

    assert head_elem ==  
      "<head><title>Foo</title></head>"
  end

  test "body element - container" do
    body_elem = body(
      hdiv(nil, id: "foo")
    )
    |> render_to_string

    IO.inspect body_elem

    assert body_elem ==  
      "<body><div id=\"foo\"></div></body>"
  end

  test "form element - container" do
    form_elem = form(
      input(id: "foo")
    )
    |> render_to_string

    IO.inspect form_elem

    assert form_elem ==  
      "<form><input id=\"foo\"/></form>"
  end

  test "div element - container, empty" do
    div_elem = hdiv(nil, id: "some-id")
    |> render_to_string

    IO.inspect div_elem

    assert div_elem == ~s(<div id="some-id"></div>)
  end

  test "div element - container, none empty" do
    div_elem = hdiv([input(id: "input-id")], id: "some-id")
    |> render_to_string

    IO.inspect div_elem

    assert div_elem ==
      ~s(<div id="some-id"><input id="input-id"/></div>)
  end

  test "custom htag" do
    elem = htag(:h2, "content", class: "foo")
    |> render_to_string()

    IO.inspect elem

    assert elem == ~s(<h2 class="foo">content</h2>)
  end
  
end
