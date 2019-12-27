defmodule HouseStatUtil.ViewController.TestController do
  @behaviour HouseStatUtil.ViewController.Controller

  import HouseStatUtil.View.TestPageView
  
  def get(_params) do
    render_result = render()
    
    cond do
      {:ok, body} = render_result -> {200, body}
      {:error, err_msg} = render_result -> {500, err_msg}
    end
  end

  def post(_params) do
    {400, "POST not allowed!"}
  end
end
