defmodule HouseStatUtil.View.ReaderPageView do
  @behaviour HouseStatUtil.View.View

  import HouseStatUtil.HTML
  import HouseStatUtil.Gettext

  def render(assigns \\ %{}) do
    rendered = ht :html do [
      render_header(),
      render_body(assigns)
    ] end
    |> render_to_string()
    
    {:ok, rendered}
  end

  defp render_header() do
    ht :head do
      ht :title do
        gettext("House Stat Util")
      end
    end
  end

  defp render_body(assigns) do
    ht :body do [
      ht :h2 do
        gettext("Submit values to openHAB")
      end,
      render_form(assigns)
    ] end
  end

  defp render_form(assigns) do
    ht :form, action: "/submit_readers", method: "post" do [
      render_reader_inputs(Map.get(assigns, :reader_inputs, %{})),
      ht :input, type: "submit", value: gettext("Submit") do end
    ] end
  end

  defp render_reader_inputs(reader_inputs) do
    reader_inputs
    |> Enum.map(&render_reader/1)
  end

  defp render_reader(reader) do
    ht :div do [
      ht :input, type: "checkbox", name: "selected_" <> to_string(reader.tag) do end,
      ht :input, type: "text", name: "reader_value_" <> to_string(reader.tag) do end,
      ht :span do reader.display_name end
    ] end
  end
end
