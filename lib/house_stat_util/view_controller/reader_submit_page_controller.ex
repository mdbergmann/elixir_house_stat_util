defmodule HouseStatUtil.ViewController.ReaderSubmitPageController do
  @behaviour HouseStatUtil.ViewController.Controller

  alias HouseStatUtil.OpenHab.RestInserter
  alias HouseStatUtil.OpenHab.ReaderValue

  import HouseStatUtil.HTML
  import HouseStatUtil.Gettext

  require Logger

  @openhab_base_url Application.get_env(:elixir_house_stat_util, :openhab_base_url)
  
  def post(form_data) do
    Logger.debug("Got form data: #{inspect form_data}")

    post_results = form_data
    |> form_data_to_reader_values()
    |> post_reader_values()

    Logger.debug("Have results: #{inspect post_results}")

    post_send_status_tuple(post_results)
    |> create_response    
  end

  defp form_data_to_reader_values(form_data) do
    form_data
    |> Enum.filter(&(String.starts_with?(elem(&1, 0), "selected_")))
    |> IO.inspect
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.map(&(String.split(&1, "_")))
    |> Enum.map(&List.last/1)
    |> Enum.map(&({String.to_atom(&1), form_data["reader_value_" <> &1]}))
    |> Enum.map(fn r ->
      type = elem(r, 0)
      value = elem(r, 1)
      %ReaderValue{
        id: determine_reader_id(type),
        value: elem(Float.parse(value), 0),
        base_url: @openhab_base_url
      }
    end)
  end

  defp post_reader_values(reader_values) do
    reader_values
    |> Enum.map(&RestInserter.post/1)
  end
  
  defp post_send_status_tuple(post_results) do
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
     ht :html do
       ht :body do [
         ht :span do msg end,
         ht :br do end,
         ht :a, href: "/" do
           gettext("Back to input!")
         end
       ] end
     end |> render_to_string()
    }
  end

  defp determine_reader_id(:elec), do: "ElecReaderStateInput"
  defp determine_reader_id(:water), do: "WaterReaderStateInput"
  defp determine_reader_id(:chip), do: "ChipReloadVolumeInput"
  defp determine_reader_id(_), do: raise "Unknown reader type!"
  
  def get(_params) do
    {400, dgettext("error", "Not supported!")}
  end
  
end
