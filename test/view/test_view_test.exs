defmodule HouseStatUtil.View.TestViewTest do
  use ExUnit.Case

  use Eml
  use Eml.HTML
  
  alias HouseStatUtil.View.TestView
  
  test "/test view with empty params" do
    rendered = TestView.render(%{})

    assert rendered == {:ok,
                        html do
                          body do
                            "foo"
                          end
                        end |> Eml.compile}
  end
  
end
