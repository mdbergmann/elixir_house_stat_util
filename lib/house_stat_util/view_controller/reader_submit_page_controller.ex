defmodule HouseStatUtil.ViewController.ReaderSubmitPageController do
  @behaviour HouseStatUtil.ViewController.Controller

  alias HouseStatUtil.OpenHab.RestInserter
  alias HouseStatUtil.OpenHab.ReaderValue

  import HouseStatUtil.HTML
  
  require Logger
  
  def post(params) do

    post_results = params
    |> Enum.filter(&(String.starts_with?(elem(&1, 0), "selected_")))
    |> IO.inspect
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.map(&(String.split(&1, "_")))
    |> Enum.map(&List.last/1)
    |> Enum.map(&({String.to_atom(&1), params["reader_value_" <> &1]}))
    |> Enum.map(fn r ->
      type = elem(r, 0)
      value = elem(r, 1)
      %ReaderValue{
        id: determine_reader_id(type),
        value: elem(Float.parse(value), 0),
        base_url: "http://localhost:8080/rest/items/"
      }
    end)
    |> Enum.map(&RestInserter.post/1)

    Logger.info("Have results: #{inspect post_results}")

    create_status_tuple(post_results)
    |> create_response    
  end

  defp create_status_tuple(post_results) do
    cond do
      Enum.all?(post_results, &(elem(&1, 0) == :ok)) -> {200, ""}
      true -> {
        500,
        Enum.filter(post_results, &(elem(&1, 0) == :error))
        |> Enum.map(&(elem(&1, 1)))
        |> Enum.join(", ")}
    end
  end

  defp create_response({status, msg}) do
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

  defp determine_reader_id(:elec), do: "ElecReaderStateInput"
  defp determine_reader_id(:water), do: "WaterReaderStateInput"
  defp determine_reader_id(:chip), do: "ChipReloadVolumeInput"
  defp determine_reader_id(_), do: raise "Unknown reader type!"
  
  def get(_params) do
    {400, "Not supported!"}
  end
  
end
