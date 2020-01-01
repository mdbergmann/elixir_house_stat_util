defmodule HouseStatUtil.HTML do

  use Eml
  alias Eml.HTML
  alias Eml.Element, as: E

  @type attr :: {:an_attr, binary()} | HTML.attr
  @type string_result :: binary() | { :safe, binary() }
  @type content :: [%E{}] | %E{} | string_result()
  @type tag_result :: %E{} | string_result()
  @type render_input :: tag_result()
  
  # @spec htag(
  #   atom(),
  #   content() | nil,
  #   [attr()]) :: tag_result()
  # def htag(tag, content \\ nil, attrs \\ []) do
  #   map_attrs = attrs |> Enum.into(%{})

  #   %E{tag: tag, attrs: map_attrs, content: content}    
  # end

  @spec ht(atom(),[attr()], do: content() | nil) :: tag_result()
  def ht(tag, attrs \\ [], do: content) do
    map_attrs = attrs |> Enum.into(%{})

    %E{tag: tag, attrs: map_attrs, content: content}
  end

  # defmacro htm(tag, attrs \\ [], do: content) do
  #   IO.puts "tag: #{inspect(tag)}"
  #   IO.puts "attrs: #{inspect(attrs)}"
  #   IO.puts "content: #{inspect(content)}"
  #   quote do
  #     map_attrs = unquote(attrs) |> Enum.into(%{})
  #     IO.inspect map_attrs

  #     unquoted_content = unquote(elem(content, 2))
  #     IO.inspect unquoted_content
      
  #     %E{tag: unquote(tag), attrs: map_attrs, content: unquoted_content}
  #   end
  # end
  
  @spec render_to_string(render_input()) :: string_result()
  def render_to_string(elem) do
    elem |> Eml.compile(quotes: :double)
  end

end
