defmodule HouseStatUtil.OpenHab.ReaderValue do

  @enforce_keys [:id, :value, :base_url]
  defstruct [:id, :value, :base_url]

  @type t() :: %__MODULE__{
    id: String.t(),
    value: float(),
    base_url: String.t()
  }

  @spec url(ReaderValue.t()) :: String.t()
  def url(reader_value) do
    reader_value.base_url <> to_string(reader_value.id)
  end

  @spec value_as_string(ReaderValue.t()) :: String.t()
  def value_as_string(reader_value) do
    to_string(reader_value.value)
  end
  
end
