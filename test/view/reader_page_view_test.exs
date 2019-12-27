defmodule HouseStatUtil.View.ReaderPageViewTest do
  use ExUnit.Case

  use Eml
  use Eml.HTML

  import HouseStatUtil.View.ReaderPageView
  
  test "Render form components, empty reader inputs" do
    {render_result, render_string} = render()

    IO.inspect render_result
    IO.inspect render_string
    
    assert render_result == :ok
    assert String.contains?(
      render_string,
      h2("Submit values to openHAB") |> Eml.compile
    )
    assert String.contains?(
      render_string,
      form action: "/" do
      end |> Eml.compile
    )
  end
  
end
