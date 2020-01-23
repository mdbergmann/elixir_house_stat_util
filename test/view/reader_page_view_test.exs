defmodule HouseStatUtil.View.ReaderPageViewTest do
  use ExUnit.Case

  import HouseStatUtil.HTML
  alias HouseStatUtil.HTML
  require HouseStatUtil.HTML
  
  alias HouseStatUtil.View.ReaderEntryUI
  import HouseStatUtil.View.ReaderPageView
  
  
  test "has form header" do
    {render_result, render_string} = render()

    assert render_result == :ok
    assert String.contains?(
      render_string,
      h2 do "Submit values to openHAB" end |> render_to_string()
    )
  end

  test "Render form components, empty reader inputs" do
    {render_result, render_string} = render()

    IO.inspect render_result
    IO.inspect render_string
    
    assert String.contains?(
      render_string,
      form action: "/submit_readers", method: "post" do
        input type: "submit", value: "Submit"
      end |> render_to_string
    )
  end
  
  test "Render form components, with reader inputs" do
    readers = [
      %ReaderEntryUI{
        tag: :elec,
        display_name: "Electricity Reader"
      },
      %ReaderEntryUI{
        tag: :water,
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

    expected_elec_reader = reader_view_for_reader_ui(hd(readers))
    expected_water_reader = reader_view_for_reader_ui(List.last(readers))

    assert String.contains?(render_string, expected_elec_reader)
    assert String.contains?(render_string, expected_water_reader)
    assert String.contains?(
      render_string,
      input(type: "submit", value: "Submit") |> render_to_string
    )
    
  end

  defp reader_view_for_reader_ui(reader_ui) do
    HTML.div do
      input type: "checkbox", name: "selected_" <> to_string(reader_ui.tag)
      input type: "text", name: "reader_value_" <> to_string(reader_ui.tag)
      span do: reader_ui.display_name
    end |> render_to_string
  end
end
