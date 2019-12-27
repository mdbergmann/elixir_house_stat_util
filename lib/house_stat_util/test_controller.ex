defmodule HouseStatUtil.TestController do

  def get(params) do
    IO.inspect params
    {200, "<html><body>foo</body></html>"}
  end
  
end
