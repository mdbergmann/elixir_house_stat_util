defmodule HouseStatUtil.View.ReaderPageView do
  @behaviour HouseStatUtil.View.View

  import HouseStatUtil.HTML
  alias HouseStatUtil.HTML
  require HouseStatUtil.HTML

  import HouseStatUtil.Gettext

  def render(assigns \\ %{}) do
    rendered = html do
      render_header()
      render_body(assigns)
    end
    |> render_to_string()
    
    {:ok, rendered}
  end

  defp render_header() do
    head do
      title do
        gettext("House Stat Util")
      end
    end
  end

  defp render_body(assigns) do
    body do
      h2 do
        gettext("Submit values to openHAB")
      end
      render_form(assigns)
    end
  end

  defp render_form(assigns) do
    form action: "/submit_readers", method: "post" do
      render_reader_inputs(Map.get(assigns, :reader_inputs, %{}))
      input type: "submit", value: gettext("Submit")
    end
  end

  defp render_reader_inputs(reader_inputs) do
    reader_inputs
    |> Enum.map(&render_reader/1)
  end

  defp render_reader(reader) do
    HTML.div do
      input type: "checkbox", name: "selected_" <> to_string(reader.tag)
      input type: "text", name: "reader_value_" <> to_string(reader.tag)
      span do: reader.display_name
    end
  end
end
