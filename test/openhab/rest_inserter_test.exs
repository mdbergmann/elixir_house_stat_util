defmodule OpenHab.RestInserterTest do
  use ExUnit.Case

  import Mock
  alias HTTPoison
  alias HouseStatUtil.OpenHab.ReaderValue
  alias HouseStatUtil.OpenHab.RestInserter

  @reader_value %ReaderValue{
    id: "1",
    value: 123.4,
    base_url: "http://localhost:8080/rest/items/"
  }
  
  test "post reader value, ok" do
    expected_url = @reader_value.base_url <> to_string(@reader_value.id)
    expected_body = to_string(@reader_value.value)
    
    with_mock HTTPoison,
      [post: fn(_url, _body, _headers) ->
        {:ok, %HTTPoison.Response{status_code: 200}} end] do

      assert {:ok, _} = RestInserter.post(@reader_value)
      
      assert called HTTPoison.post(expected_url, expected_body, :_)
    end
  end
  
  test "post reader value, error" do
    expected_url = @reader_value.base_url <> to_string(@reader_value.id)
    expected_body = to_string(@reader_value.value)
    
    with_mock HTTPoison,
      [post: fn(_url, _body, _headers) ->
        {:error, %HTTPoison.Error{id: nil, reason: :econnrefused}} end] do

      assert {:error, _} = RestInserter.post(@reader_value)
      
      assert called HTTPoison.post(expected_url, expected_body, :_)
    end
  end
end
