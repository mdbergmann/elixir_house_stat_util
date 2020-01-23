defmodule HouseStatUtil.HTML do

  require Eml
  alias Eml.Element, as: E

  @type attr :: {:an_attr, binary()} | HTML.attr
  @type string_result :: binary() | { :safe, binary() }
  @type content :: [%E{}] | %E{} | string_result()
  @type tag_result :: %E{} | string_result()
  @type render_input :: tag_result()

  @tags [:html, :head, :title, :base, :link, :meta, :style,
         :script, :noscript, :body, :div, :span, :article,
         :section, :nav, :aside, :h1, :h2, :h3, :h4, :h5, :h6,
         :header, :footer, :address, :p, :hr, :pre, :blockquote,
         :ol, :ul, :li, :dl, :dt, :dd, :figure, :figcaption, :main,
         :a, :em, :strong, :small, :s, :cite, :q, :dfn, :abbr, :data,
         :time, :code, :var, :samp, :kbd, :sub, :sup, :i, :b, :u, :mark,
         :ruby, :rt, :rp, :bdi, :bdo, :br, :wbr, :ins, :del, :img, :iframe,
         :embed, :object, :param, :video, :audio, :source, :track, :canvas, :map,
         :area, :svg, :math, :table, :caption, :colgroup, :col, :tbody, :thead, :tfoot,
         :tr, :td, :th, :form, :fieldset, :legend, :label, :input, :button, :select,
         :datalist, :optgroup, :option, :textarea, :keygen, :output, :progress,
         :meter, :details, :summary, :menuitem, :menu]

  for tag <- @tags do
    defmacro unquote(tag)(attrs, do: inner) do
      tag = unquote(tag)
      quote do: HouseStatUtil.HTML.tag(unquote(tag), unquote(attrs), do: unquote(inner))
    end

    defmacro unquote(tag)(attrs \\ []) do
      tag = unquote(tag)
      quote do: HouseStatUtil.HTML.tag(unquote(tag), unquote(attrs))
    end
  end

  defmacro tag(name, attrs \\ []) do
    {inner, attrs} = Keyword.pop(attrs, :do)
    quote do: HouseStatUtil.HTML.tag(unquote(name), unquote(attrs), do: unquote(inner))
  end

  defmacro tag(name, attrs, do: inner) do
    IO.puts "tag(name): #{inspect(name)}"
    IO.puts "tag(attrs): #{inspect(attrs)}"
    IO.puts "tag(inner): #{inspect(inner)}"

    parsed_inner = parse_inner_content(inner)
    IO.puts "parsed_inner: #{inspect(parsed_inner)}"
    
    ast = quote do
      %E{tag: unquote(name),
         attrs: Enum.into(unquote(attrs), %{}),
         content: unquote(parsed_inner)}
    end
    IO.puts "ast: #{Macro.to_string(ast)}"
    ast
  end

  defp parse_inner_content({:__block__, _, items}), do: items
  defp parse_inner_content(inner), do: inner
  
  @spec render_to_string(render_input()) :: string_result()
  def render_to_string(elem) do
    elem |> Eml.compile(quotes: :double)
  end

end
