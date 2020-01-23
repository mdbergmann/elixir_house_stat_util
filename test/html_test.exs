defmodule HouseStatUtil.HTMLTest do
  use ExUnit.Case

  alias HouseStatUtil.HTML
  import HTML
  require HTML
  
  test "single element with attributes" do
    elem = input(id: "some-id", name: "some-name", value: "some-value")
    |> render_to_string

    IO.inspect elem

    assert String.starts_with?(elem, "<input")
    assert String.contains?(elem, ~s(id="some-id"))
    assert String.contains?(elem, ~s(name="some-name"))
    assert String.contains?(elem, ~s(value="some-value"))
    assert String.ends_with?(elem, "/>")
  end

  test "multiple sub elements - container" do
    html_elem = html class: "foo" do
      head
      body class: "bar"
    end
    |> render_to_string

    IO.inspect html_elem

    assert String.ends_with?(html_elem, 
      "<html class=\"foo\"><head></head><body class=\"bar\"></body></html>")
  end

  test "more sophisticated thing" do
    html_elem = html id: "1", class: "foo" do
      head do
        "My title"
      end
      body class: "body_class" do
        HTML.div id: "5", class: "div_class" do
          form action: "post" do
            input id: "in1", type: "checkbox"
            input id: "in2", type: "text"
            input id: "submit", type: "submit"
          end
        end
      end
    end
    |> render_to_string()

    IO.inspect html_elem

    assert String.contains?(html_elem, "<!doctype html>")
    assert String.contains?(html_elem, "<html class=\"foo\" id=\"1\">")
    assert String.contains?(html_elem, "<head>My title</head>")
    assert String.contains?(html_elem, "<body class=\"body_class\">")
    assert String.contains?(html_elem, "<div class=\"div_class\" id=\"5\">")
    assert String.contains?(html_elem, "<form action=\"post\">")
    assert String.contains?(html_elem, "<input id=\"in1\" type=\"checkbox\"/>")
    assert String.contains?(html_elem, "<input id=\"in2\" type=\"text\"/>")
    assert String.contains?(html_elem, "<input id=\"submit\" type=\"submit\"/>")
    assert String.contains?(html_elem, "</form>")
    assert String.contains?(html_elem, "</div>")
    assert String.contains?(html_elem, "</body>")
    assert String.contains?(html_elem, "</html>")
    
  end
end

