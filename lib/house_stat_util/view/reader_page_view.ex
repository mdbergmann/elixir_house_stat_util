defmodule HouseStatUtil.View.ReaderPageView do
  @behaviour HouseStatUtil.View.View

  use Eml
  use Eml.HTML
  
  def render(assigns \\ %{}) do
    body = html do
      render_header()
      render_body(assigns)
    end
    |> Eml.compile()
    
    {:ok, body}
  end

  defp render_header() do
    head do
      title do
        "House Stat Util"
      end
    end
  end

  defp render_body(assigns) do
    body do
      h2 do
        "Submit values to openHAB"
      end
      render_form(assigns)
    end
  end

  defp render_form(assigns) do
    form action: "/" do
      render_reader_inputs(Map.get(assigns, "reader_inputs", %{}))
    end
  end

  defp render_reader_inputs(reader_inputs) do
    reader_inputs
    |> Enum.map(fn ri ->
      div do
        input type: "checkbox", name: "selected"
        input type: "text", name: "reader_value"
        span ri.display_name
      end    
    end)
  end
end
