defmodule HouseStatUtil.View.View do
  @callback render(assigns :: %{binary() => any()}) :: {:ok, binary()} | {:error, binary()}
end
