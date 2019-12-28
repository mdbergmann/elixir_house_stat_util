defmodule HouseStatUtil.View.ReaderPageViewTest do
  use ExUnit.Case

  use Eml
  use Eml.HTML

  alias HouseStatUtil.View.ReaderEntryUI
  import HouseStatUtil.View.ReaderPageView
  
  
  test "has form header" do
    {render_result, render_string} = render()

    assert render_result == :ok
    assert String.contains?(
      render_string,
      h2("Submit values to openHAB") |> Eml.compile
    )
  end

  test "Render form components, empty reader inputs" do
    {render_result, render_string} = render()

    IO.inspect render_result
    IO.inspect render_string
    
    assert String.contains?(
      render_string,
      form action: "/" do
      end |> Eml.compile
    )
  end
  
  test "Render form components, with reader inputs" do
    readers = [
      %ReaderEntryUI{
        display_name: "Electricity Reader"
      },
      %ReaderEntryUI{
        display_name: "Water Reader"
      }
    ]
    
    {render_result, render_string} = render(
      %{
        :reader_inputs => readers
      }
    )

    IO.inspect render_result
    IO.inspect render_string

    Enum.map(readers, &(reader_view_for_reader_ui(&1)))
    |> Enum.all?(&(String.contains?(render_string, &1)))
    
  end

  defp reader_view_for_reader_ui(reader_ui) do
    div do
      input type: "checkbox", name: "selected"
      input type: "text", name: "reader_value"
      span reader_ui.display_name
    end |> Eml.compile    
  end
end
