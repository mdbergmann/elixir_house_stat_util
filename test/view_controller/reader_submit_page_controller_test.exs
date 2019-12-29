defmodule HouseStatUtil.ViewController.ReaderSubmitPageControllerTest do
  use ExUnit.Case

  import Mock
  alias HouseStatUtil.ViewController.ReaderSubmitPageController
  alias HouseStatUtil.OpenHab.RestInserter
  alias HouseStatUtil.OpenHab.ReaderValue

  @reader_data %{
    "reader_value_chip" => "",
    "reader_value_elec" => "1123.6",
    "reader_value_water" => "4567",
    "selected_elec" => "on",
    "selected_water" => "on"
  }
  
  test "handle GET" do
    assert {400, "Not supported!"} = ReaderSubmitPageController.get(%{})
  end

  test "handle POST - no reader selection" do
    reader_data = %{
      "reader_value_chip" => "",
      "reader_value_elec" => "1123",
      "reader_value_water" => "4567"
    }
    
    assert {200, _} = ReaderSubmitPageController.post(reader_data)
  end

  test "handle POST - with reader selection" do
    expected_elec_reader_value = %ReaderValue{
      id: "ElecReaderStateInput",
      value: 1123.6,
      base_url: "http://localhost:8080/rest/items/"
    }
    expected_water_reader_value = %ReaderValue{
      id: "WaterReaderStateInput",
      value: 4567.0,
      base_url: "http://localhost:8080/rest/items/"
    }
    
    with_mock RestInserter,
      [post: fn _reader -> {:ok, ""} end] do

      assert {200, _} = ReaderSubmitPageController.post(@reader_data)
      
      assert called RestInserter.post(expected_elec_reader_value)
      assert called RestInserter.post(expected_water_reader_value)
    end
  end

  test "handle POST - with reader selection - one error on submit" do

    expected_elec_reader_value = %ReaderValue{
      id: "ElecReaderStateInput",
      value: 1123.6,
      base_url: "http://localhost:8080/rest/items/"
    }
    expected_water_reader_value = %ReaderValue{
      id: "WaterReaderStateInput",
      value: 4567.0,
      base_url: "http://localhost:8080/rest/items/"
    }
    
    with_mock RestInserter,
      [post: fn reader ->
        case reader.id do
          "ElecReaderStateInput" -> {:ok, ""}
          "WaterReaderStateInput" -> {:error, "Error on submitting water reader!"}
        end
      end] do

      assert {500, _} =
        ReaderSubmitPageController.post(@reader_data)
      
      assert called RestInserter.post(expected_elec_reader_value)
      assert called RestInserter.post(expected_water_reader_value)
    end
  end
end
