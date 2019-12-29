defmodule HouseStatUtil.View.TestViewTest do
  use ExUnit.Case

  use Eml
  use Eml.HTML
  
  alias HouseStatUtil.View.TestPageView
  
  test "/test view with empty params" do
    rendered = TestPageView.render(%{})

    assert rendered == {:ok,
                        html do
                          body do
                            "foo"
                          end
                        end |> Eml.compile}
  end
  
end
