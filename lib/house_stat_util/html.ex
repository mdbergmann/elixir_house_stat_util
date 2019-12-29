defmodule HouseStatUtil.HTML do

  use Eml
  alias Eml.HTML
  alias Eml.Element, as: E

  @type attr :: {:an_attr, binary()} | HTML.attr
  @type string_result :: binary() | { :safe, binary() }
  @type content :: [%E{}] | %E{} | string_result()
  @type tag_result :: %E{} | string_result()
  @type render_input :: tag_result()
  
  @spec input([attr()]) :: %E{}
  def input(attrs) do
    htag(:input, nil, attrs)
  end

  @spec html(content(), [attr()]) :: tag_result()
  def html(content, attrs \\ []) do
    htag(:html, content, attrs)
  end  
  
  @spec head(content(), [attr()]) :: tag_result()
  def head(content, attrs \\ []) do
    htag(:head, content, attrs)
  end  

  @spec body(content(), [attr()]) :: tag_result()
  def body(content, attrs \\ []) do
    htag(:body, content, attrs)
  end  

  @spec form(content(), [attr()]) :: tag_result()
  def form(content, attrs \\ []) do
    htag(:form, content, attrs)
  end  

  @spec hdiv(content(), [attr()]) :: tag_result()
  def hdiv(content, attrs \\ []) do
    htag(:div, content, attrs)
  end

  @spec htag(
    atom(),
    content() | nil,
    [attr()]) :: tag_result()
  def htag(tag, content \\ nil, attrs \\ []) do
    map_attrs = attrs |> Enum.into(%{})

    %E{tag: tag, attrs: map_attrs, content: content}    
  end
  
  @spec render_to_string(render_input()) :: string_result()
  def render_to_string(elem) do
    elem |> Eml.compile(quotes: :double)
  end
  
end
