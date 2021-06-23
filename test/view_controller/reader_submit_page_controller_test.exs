defmodule HouseStatUtil.ViewController.ReaderSubmitPageControllerTest do
  use ExUnit.Case

  import Mock
  alias HouseStatUtil.ViewController.ReaderSubmitPageController
  alias HouseStatUtil.OpenHab.RestInserter
  alias HouseStatUtil.OpenHab.ReaderValue

  @openhab_url Application.get_env(:elixir_house_stat_util, :openhab_base_url)
  
  @reader_data %{
    "reader_value_chip" => "",
    "reader_value_elec" => "1123.6",
    "reader_value_water" => "4567",
    "reader_value_watergarden" => "9876",
    "selected_elec" => "on",
    "selected_water" => "on",
    "selected_watergarden" => "on"
  }

  @expected_elec_reader_value %ReaderValue{
    id: "ElecReaderStateInput",
    value: 1123.6,
    base_url: @openhab_url
  }
  @expected_water_reader_value %ReaderValue{
    id: "WaterReaderStateInput",
    value: 4567.0,
    base_url: @openhab_url
  }
  @expected_watergarden_reader_value %ReaderValue{
    id: "GardenWaterReaderStateInput",
    value: 9876.0,
    base_url: @openhab_url
  }
  
  test "handle GET" do
    assert {400, "Not supported!"} = ReaderSubmitPageController.get(%{})
  end

  test "handle POST - no reader selection" do
    reader_data = %{
      "reader_value_chip" => "",
      "reader_value_elec" => "1123",
      "reader_value_water" => "4567",
      "reader_value_watergarden" => "9876"
    }
    
    assert {200, _} = ReaderSubmitPageController.post(reader_data)
  end

  test "handle POST - with reader selection" do
    with_mock RestInserter,
      [post: fn _reader -> {:ok, ""} end] do

      assert {200, _} = ReaderSubmitPageController.post(@reader_data)
      
      assert called RestInserter.post(@expected_elec_reader_value)
      assert called RestInserter.post(@expected_water_reader_value)
    end
  end

  test "handle POST - with reader selection - one error on submit" do
    with_mock RestInserter,
      [post: fn reader ->
        case reader.id do
          "ElecReaderStateInput" -> {:ok, ""}
          "GardenWaterReaderStateInput" -> {:ok, ""}
          "WaterReaderStateInput" -> {:error, "Error on submitting water reader!"}
        end
      end] do

      {500, err_msg} = ReaderSubmitPageController.post(@reader_data)
      assert String.contains?(err_msg, "Error on submitting water reader!")
      
      assert called RestInserter.post(@expected_elec_reader_value)
      assert called RestInserter.post(@expected_water_reader_value)
      assert called RestInserter.post(@expected_watergarden_reader_value)
    end
  end
end
