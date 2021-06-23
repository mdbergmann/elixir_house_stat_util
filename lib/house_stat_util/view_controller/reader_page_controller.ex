defmodule HouseStatUtil.ViewController.ReaderPageController do
  @behaviour HouseStatUtil.ViewController.Controller

  alias HouseStatUtil.ViewController.Controller
  
  alias HouseStatUtil.View.ReaderEntryUI
  import HouseStatUtil.View.ReaderPageView

  @default_readers [
    %ReaderEntryUI{
      tag: :elec,
      display_name: "Electricity Reader"
    },
    %ReaderEntryUI{
      tag: :water,
      display_name: "Water Reader"
    },
    %ReaderEntryUI{
      tag: :watergarden,
      display_name: "Water Reader (Garden)"
    },
    %ReaderEntryUI{
      tag: :chip,
      display_name: "Chip Reload Volume"
    }
  ]

  @impl Controller
  def get(_params) do
    render_result = render(
      %{
        :reader_inputs => @default_readers
      }
    )

    cond do
      {:ok, body} = render_result -> {200, body}
    end
  end

  @impl Controller
  def post(_params) do
    {400, ""}
  end
  
end
