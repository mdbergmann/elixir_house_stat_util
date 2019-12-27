defmodule HouseStatUtil.ViewController.ReaderPageController do
  @behaviour HouseStatUtil.ViewController.Controller

  import HouseStatUtil.View.ReaderPageView
  
  def get(_params) do
    render_result = render()

    cond do
      {:ok, body} = render_result -> {200, body}
    end
  end

  def post(_params) do
    {400, ""}
  end
  
end
