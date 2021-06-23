defmodule HouseStatUtil.View.ReaderEntryUI do
  @moduledoc """
  Possible tags: `:elec`, `:water`, `:water_garden`, `:chip`.
  """
  
  @enforce_keys [:tag, :display_name]
  defstruct [
    tag: nil,
    selected: false,
    value: "",
    display_name: ""
  ]

  @type t() :: %__MODULE__{
    tag: atom(),
    selected: boolean(),
    value: binary(),
    display_name: binary()
  }

end
