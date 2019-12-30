defmodule HouseStatUtil.OpenHab.RestInserter do

  alias HTTPoison
  alias HouseStatUtil.OpenHab.ReaderValue

  @spec post(ReaderValue.t()) :: {atom(), any()}
  def post(reader_value) do
    HTTPoison.post(
      ReaderValue.url(reader_value),
      ReaderValue.value_as_string(reader_value),
      [{"Content-Type", "text/plain"}]
    )
  end
  
end
