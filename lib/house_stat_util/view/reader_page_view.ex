defmodule HouseStatUtil.View.ReaderPageView do
  @behaviour HouseStatUtil.View.View

  import HouseStatUtil.HTML
  import HouseStatUtil.Gettext

  def render(assigns \\ %{}) do
    rendered = html(
      [
        render_header(),
        render_body(assigns)
      ]
    )
    |> render_to_string()
    
    {:ok, rendered}
  end

  defp render_header() do
    head([
      htag(:title, gettext("House Stat Util"))
    ])
  end

  defp render_body(assigns) do
    body(
      [
        htag(:h2, gettext("Submit values to openHAB")),
        render_form(assigns)
      ]
    )
  end

  defp render_form(assigns) do
    form(
      [
        render_reader_inputs(Map.get(assigns, :reader_inputs, %{})),
        input(type: "submit", value: gettext("Submit"))
      ],
      action: "/submit_readers",
      method: "post"
    )
  end

  defp render_reader_inputs(reader_inputs) do
    reader_inputs
    |> Enum.map(&render_reader/1)
  end

  defp render_reader(reader) do
    hdiv(
      [
        input(type: "checkbox", name: "selected_" <> to_string(reader.tag)),
        input(type: "text", name: "reader_value_" <> to_string(reader.tag)),
        htag(:span, reader.display_name)
      ]
    )
  end
end
