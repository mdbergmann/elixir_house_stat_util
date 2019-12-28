defmodule HouseStatUtil.View.ReaderEntryUI do

  @enforce_keys [:display_name]
  defstruct [
    selected: false,
    value: "",
    display_name: ""
  ]

  @type t() :: %__MODULE__{
    selected: boolean(),
    value: binary(),
    display_name: binary()
  }

end
