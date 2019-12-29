defmodule HouseStatUtil.ViewController.ReaderSubmitPageController do
  @behaviour HouseStatUtil.ViewController.Controller

  alias HouseStatUtil.OpenHab.RestInserter
  alias HouseStatUtil.OpenHab.ReaderValue

  import HouseStatUtil.HTML
  
  require Logger
  
  def post(params) do

    results = params
    |> Enum.filter(&(String.starts_with?(elem(&1, 0), "selected_")))
    |> IO.inspect
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.map(&(String.split(&1, "_")))
    |> Enum.map(&List.last/1)
    |> Enum.map(&({String.to_atom(&1), params["reader_value_" <> &1]}))
    |> Enum.map(fn r ->
      type = elem(r, 0)
      value = elem(r, 1)
      reader_id =
        case type do
          :elec -> "ElecReaderStateInput"
          :water -> "WaterReaderStateInput"
          :chip -> "ChipReloadVolumeInput"
        end
      %ReaderValue{
        id: reader_id,
        value: elem(Float.parse(value), 0),
        base_url: "http://localhost:8080/rest/items/"
      }
    end)
    |> Enum.map(fn r ->
      RestInserter.post(r)
    end)

    Logger.info("Have results: #{inspect results}")

    {status, msg} = cond do
      Enum.all?(results, &(elem(&1, 0) == :ok)) -> {200, ""}
      true -> {500, "Not all readers submitted OK!"}
    end
    
    {status,
     html(
       body(
         [
           htag(:span, msg),
           htag(:br),
           htag(:a, "Back to input!", href: "/")
         ]
       )
     ) |> render_to_string()
    }
  end
  
  def get(_params) do
    {400, "Not supported!"}
  end
  
end
