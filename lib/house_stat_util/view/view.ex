defmodule HouseStatUtil.View.View do
  @type string_result :: binary() | { :safe, binary() }
  
  @callback render(
    assigns :: %{binary() => any()}) :: {:ok, string_result()} | {:error, string_result()}
end
