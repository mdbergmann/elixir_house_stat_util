defmodule HouseStatUtil.HTML do

  use Eml
  alias Eml.HTML

  @type attr :: {:an_attr, binary()} | HTML.attr
  
  @spec input([attr()]) :: %Eml.Element{tag: :input, attrs: map()}
  def input(attrs) do
    map_attrs = attrs
    |> Enum.into(%{})

    %Eml.Element{tag: :input, attrs: map_attrs}
  end

  def generate_string(elem) do
    elem |> Eml.compile(quotes: :double)
  end
  
end
