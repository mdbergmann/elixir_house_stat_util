defmodule HouseStatUtil.View.TestPageView do
  @behaviour HouseStatUtil.View.View
  
  use Eml
  use Eml.HTML
  
  def render(assigns \\ %{}) do
    {:ok, 
     html do
       body do
         "foo"
       end
     end |> Eml.compile()
    }
  end
  
end
