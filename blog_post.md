# Developing a simple MVC framework in Elixir

I did explore [Elixir](https://elixir-lang.org) in the last half year.  
It's a fantastic language. Relatively young but already mature. It runs on the solid and battle proven Erlang VM.

Now I thought it is time to have a look at the web framework [Phoenix](https://www.phoenixframework.org).

After reading a few things and trying my way through [Programming Phoenix](https://pragprog.com/book/phoenix14/programming-phoenix-1-4) I didn't really understand what's going on underneath this abstraction that Phoenix has built. There seemed to be a lot of magic happening. So I wanted to understand that first.

Of course a lot of brilliant work has gone into Phoenix. However, for some key components like the web server, the request routing, the template library Phoenix more or less just does the glueing.

But for me it was important to understand how the web server is integrated, and how defining routes and handlers work.  
So the result of this exploration was a simple MVC web framework.  

It is actually quite easy to develop something simple from scratch. Of course this cannot compete with Phoenix and it should not.  
However for simple web pages this might be fully sufficient and it doesn't require a large technology stack.

So I'd like to go though this step by step while crafting the code as we go. The web application will contain a simple form where I want to put in reader values of my house, like electricity or water. When those are submitted they are transmitted to my [openHAB](https://www.openhab.org) system. So you might see the name 'HouseStatUtil' more often. This is the name of the project.

Those are the components we will have a look at:

- the web server
- the request routing and how to define routes
- how to add controllers and views and the model they use
- the HTML rendering
- string resource localisation

For reference, the complete project is on [Github](https://github.com/mdbergmann/elixir_house_stat_util).

### Project setup

You use the usual `mix` tooling to create a new project.

Then we'll need some dependencies (extract from `mix.exs`):

```
  defp deps do
    [
      {:plug_cowboy, "~> 2.1.0"},
      {:eml, git: "https://github.com/zambal/eml.git"},
      {:gettext, "~> 0.17.1"},
      {:mock, "~> 0.3.4", only: :test}
    ]
  end
```

As you probably know, if you don't specify `git:` in particular `mix` will pull the dependencies from [hex](https://hex.pm). But `mix` can also deal with github projects.

- [plug_cowboy](https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html): so [Plug](https://elixirschool.com/en/lessons/specifics/plug/) is an Elixir library that makes building web applications easy. Plugs can be seen as plugins. And so is `plug_cowboy` a 'Plug' that bundles the Erlang web server [Cowboy](https://ninenines.eu).
- [Eml](https://github.com/zambal/eml): is a library for generating HTML in form of Elixir language constructs, a DSL. But as we will later see, Elixir macros are very powerful (almost as Common Lisp macros). We we will build our own HTML DSL abstraction which should make it easy to use any backend library to generate HTML.
- [gettext](https://hexdocs.pm/gettext/Gettext.html): is the default localization framework in Elixir. We will see later how that works.
- [mock](https://github.com/jjh42/mock): since we do Test-Driven Development (TDD) of course we need a mocking framework. A library for unit tests is not necessary. This is part of the core Elixir. 

### The web server

[Cowboy](https://ninenines.eu) is probably the most well known and used web server in the Erlang world. But we don't have to deal with the details that much.

We have to tell the Erlang runtime to start Cowboy as a separate 'application' in the VM. The term 'application' is a bit misleading. You should see this more as a module or component.

Since in Erlang most things are actor based, and you can have a hierarchy and eventually a tree of actors that are spawned in an 'application' (or component) you have to at least make sure that those components are up and running before you use them.

So we'll have to add this to `application.ex` which is the application entry point and should be inside the 'lib/<project_name>' folder.

This is how it looks for my application:

```
  require Logger

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: HouseStatUtil.Router,
        options: [port: application_port()])
    ]

    opts = [strategy: :one_for_one, name: HouseStatUtil.Supervisor]
    pid = Supervisor.start_link(children, opts)
    Logger.info("Server started")

    pid
  end

  defp application_port do
    System.get_env()
    |> Map.get("PORT", "4001")
    |> String.to_integer()
  end
```

The first thing to note is that we use the Elixir `Logger` library. So we need to `require` it. (As a side note, usually you do use `import` or `alias` to import other modules. But `require` is needed when the component defines macros.)

The `start` function is called by the runtime. Now we have to define the 'children' processes we want to have started. Here we define the `Plug.Cowboy` as a child.

The line `plug: HouseStatUtil.Router` defines the request router. We'll have a look at this later.

`Supervisor.start_link(children, opts)` will then start the children actors/processes.


### Request routing and how to define routes

The `HouseStatUtil.Router` is the next step. We need to tell Cowboy how to deal with requests that come in. In  most web applications you have to define some routing, or define page beans that are mapped to some request paths.

In Elixir this is pretty slick. The language allows to call functions without parentheses like so:

```
get "/" do
	# do something
end
```

This could be written with parentheses as well: `get("/") do`

Here is the complete router module:

```
defmodule HouseStatUtil.Router do
  use Plug.Router

  alias HouseStatUtil.ViewController.ReaderPageController
  alias HouseStatUtil.ViewController.ReaderSubmitPageController
  
  plug Plug.Logger
  
  plug Plug.Parsers,
    parsers: [:urlencoded],
    pass: ["text/*"]

  plug :match
  plug :dispatch

  get "/" do
    {status, body} = ReaderPageController.get(conn.params)
    send_resp(conn, status, body)    
  end

  post "/submit_readers" do
    IO.inspect conn.params
    {status, body} = ReaderSubmitPageController.post(conn.params)
    send_resp(conn, status, body)
  end
  
  match _ do
    send_resp(conn, 404, "Destination not found!")
  end
end
```

Let's go though it.

`use Plug.Router` is the key element here. This will make this module a router. This also specifies the request types `get`, `post` and so on.  

`conn` is a connection structure which has all the data about the connection and the request, like the header and query parameters and so on. `conn.params` is a combination of payload and query parameters.

Each route definition must send a response to the client. This is done with `send_resp/3`. It does take three parameters, the connection structure, a status and a response body (which is the payload). 

All the `plug` definitions are executed in a chain for each request. Which means every request is url encoded (the request path at least) and must have a content-type of 'text/*'.

`plug :match` does the matching on the paths. The last `match _ do` is a 'catch all' match which here sends a 404 error back to the client.

As you can see we have two routes. Each route is handled by a view controller. The only thing we pass to the view controller are the connection parameters.

##### Serving static content

Most web sites need to serve static content like JavaScript, CSS or images. That is no problem. The [Plug.Static](https://hexdocs.pm/plug/Plug.Static.html) does this. As with the other plugs you just define this, maybe before `plug :match` like so:

```
plug Plug.Static, from: "priv/static"
```

The 'priv' folder, in this relative form is in your project folder on the same level as the 'lib' and 'test' folders. You can then add sub folders to 'priv/static' for images, css and javascript and define the appropriate paths in your HTML. For an image this would then be:

```
<img src="images/foo.jpg" />
```


##### Testing the router

Of course the router can be tested. The router can nicely act as an integration test.  
Add one route test after another. It will fail until you have implemented and integrated the rest of the components (view controller and view). But it will act as a north star. When it passes you can be sure that all components are integrated properly.

Here is the test code of the router:

```
defmodule HouseStatUtil.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HouseStatUtil.Router
  
  @opts HouseStatUtil.Router.init([])

  test "get on '/'" do
    conn = :get
    |> conn("/")
    |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "Submit values to openHAB")
  end

  test "post on /submit_readers" do
    conn = :post
    |> conn("/submit_readers")
    |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end
end
``` 

There is a bit of magic that is being done by the `Plug.Test`. It allows you to specify the `:get` and `:post` requests as in the tests.

After the `Router.call(@opts)` has been made we can inspect the `conn` structure and assert on various things. For the `conn.resp_body` we only have a chance to assert on some existing string in the HTML output.

This can be done better. A good example is [Apache Wicket](https://wicket.apache.org), a Java based web framework that has excellent testing capabilities. But the situation is similar on most of the MVC based frameworks. Since they are not component based the testing capabilities are somewhat limited.

Nonetheless we'll try to make it as good as possible.

Next step are the view controllers.


### How to define controllers and views and the model

#### The view controller

As you have seen above, each route uses its own view controller. I thought that a view controller can handle `get` or `post` requests on a route. So that handling more 'views' related to a path can be combined in a view controller.
But you can do that as you wish. There is no rule.

As a first step I defined a `behaviour` for a view controller. It looks like this:

```
defmodule HouseStatUtil.ViewController.Controller do
  @callback get(params :: %{binary() => any()}) :: {integer(), binary()}
  @callback post(params :: %{binary() => any()}) :: {integer(), binary()}
end
```

It defines two functions who's parameters are 'spec'ed as a map of strings -> anything (`binary()` is Erlang and is  actually something stringlike. I could also use an Elixir `string` here). And those functions return a tuple of integer (the status) and again a string (the response body).

I thought that the controller should actually define the status since it has to deal with the logic to render the view and process the form parameters, maybe call some backend or collaborator. So if anything goes wrong there the controller knows it.  
This is clearly a debatable design decision. We could argue that the controller should not necessarily know about HTTP status codes.

Here is the source for the controller:

```
defmodule HouseStatUtil.ViewController.ReaderPageController do
  @behaviour HouseStatUtil.ViewController.Controller

  alias HouseStatUtil.ViewController.Controller
  alias HouseStatUtil.View.ReaderEntryUI
  import HouseStatUtil.View.ReaderPageView

  @default_readers [
    %ReaderEntryUI{
      tag: :elec,
      display_name: "Electricity Reader"
    },
    %ReaderEntryUI{
      tag: :water,
      display_name: "Water Reader"
    }
  ]
  
  @impl Controller
  def get(_params) do
    render_result = render(
      %{
        :reader_inputs => @default_readers
      }
    )

    cond do
      {:ok, body} = render_result -> {200, body}
    end
  end

  @impl Controller
  def post(_params), do: {400, ""}
end
```

You see that this controller implements the `behaviour` specification in the `get` and `post` functions. This can optionally be marked with `@impl` to make it more visible that those are the implemented behaviours.  
A `post` is not allowed for this controller and just returns error 400.

The `get` function is the important thing here. The response body for `get` is generated by the views `render/1` function. So we have a view definition here imported as `ReaderPageView` which specifies a `render/1` function.

The views `render/1` function takes a model (a map) where we here just specify some `:reader_input` definitions. Those are later rendered as a table with checkbox, label and textfield.

The `render/1` function returns a tuple of `{[ok|error], body}`. In case of `:ok` we return a success response (200) with the rendered body.

So we already have the model in the play here that is used by both controller and view. In this case the controller creates the model that should be used by the view to render.

##### Generating HTML in the controller

For simple responses it's not absolutely necessary to actually create a view. The controller can easily generate simple HTML (in the way we describe later) and just return it. However, it should stay simple and short to not clutter the controller source code. After all it's the views responsibility to do that.

##### A view controller with submit

To support a submit you certainly have to implement the `post` function. The `post` function in the controller will receive the form parameters as a map. This is how it looks like:

```
%{
  "reader_value_chip" => "",
  "reader_value_elec" => "17917.3",
  "reader_value_water" => "",
  "selected_elec" => "on"
}
```

The keys of the map are the 'name' attributes of the form components.

Since we only want to send selected reader values to openHAB we have to filter the form parameter map for those that  were selected, which here is only the electricity reader ('reader\_value\_elec').

Here is the source of the 'submit_readers' `post` controller handler:

```
  def post(form_data) do
    Logger.debug("Got form data: #{inspect form_data}")

    post_results = form_data
    |> form_data_to_reader_values()
    |> post_reader_values()

    Logger.debug("Have results: #{inspect post_results}")

    post_send_status_tuple(post_results)
    |> create_response    
  end
```

More sophisticated frameworks like Phoenix do some pre-processing and deliver the form parameters in pre-defined or standardised structure types.  
We don't have that, so there might be a bit of manual parsing required. But we're developers, right?

##### Testing the controller

Since the controller is just a simple module it should be easy to test it. Of course it depends a bit on the dependencies of your controller if this is more or less easy. At least the controller depends on a view component where a `render/1` function is called with some model.

But the controller test shouldn't test the rendering of the view. We basically just test a bi-directional pass through here. One direction is the generated model to the views render function, and the other direction is the views render result that should be mapped to a controller result.

To avoid to really have the view render stuff in the controller test we can mock the views render function.

In my case here I have a trivial test for the `ReaderPageController` which just should render the form and doesn't require mocking (we do some mocking later).

```
defmodule HouseStatUtil.ViewController.ReaderPageControllerTest do
  use ExUnit.Case

  alias HouseStatUtil.ViewController.ReaderPageController
  
  test "handle GET" do
    assert {200, _} = ReaderPageController.get(%{})
  end

  test "handle POST returns error" do
    assert {400, _} = ReaderPageController.post(%{})
  end
end
```

The `get` test just delivers an empty model to the controller, which effectively means that no form components are rendered except the submit button.  
The `post` is not supported on this controller and hence should return a 400 error.

##### Mocking out collaborators

The situation is a bit more difficult for the submit controller `ReaderSubmitPageController`. This controller actually sends the entered and parsed reader results to the openHAB system via a REST interface. So the submit controller has a collaborator called `OpenHab.RestInserter`. This component uses [HTTPoison](https://github.com/edgurgel/httpoison) http client library to submit the values via REST.  
I don't want to pull in those dependencies in the controller test, so this is a good case to mock the `RestInserter` module.

The first thing we have to do is `import Mock` to have the defined functions available in the controller test.

As an example I have a success test case and an error test case to show how the mocking works.

The tests work on this pre-defined data:

```
  @reader_data %{
    "reader_value_chip" => "",
    "reader_value_elec" => "1123.6",
    "reader_value_water" => "4567",
    "selected_elec" => "on",
    "selected_water" => "on"
  }
  @expected_elec_reader_value %ReaderValue{
    id: "ElecReaderStateInput",
    value: 1123.6,
    base_url: @openhab_url
  }
  @expected_water_reader_value %ReaderValue{
    id: "WaterReaderStateInput",
    value: 4567.0,
    base_url: @openhab_url
  }
```

This defines submitted reader form data where reader values for water and electricity were entered and selected. So we expect that the `RestInserter` function is called with the `@expected_elec_reader_value` and `@expected_water_reader_value`.

*A success case*

```
  test "handle POST - success - with reader selection" do
    with_mock RestInserter,
      [post: fn _reader -> {:ok, ""} end] do

      assert {200, _} = ReaderSubmitPageController.post(@reader_data)
      
      assert called RestInserter.post(@expected_elec_reader_value)
      assert called RestInserter.post(@expected_water_reader_value)
    end
  end
```

The key part here is the `with_mock <module_to_be_mocked>`. The module to be mocked is the `RestInserter`.  
The line `[post: fn _reader -> {:ok, ""} end]` defines the function to be mocked, which here is the `post/1` function of `RestInserter`. We define the mocked function to return `{:ok, ""}`, which simulates a 'good' case. Within the `do end` we eventually call the controllers post function with the pre-defined submitted form data that normally would come in via the cowboy plug.

Then we want to assert that `RestInserter`s `post/1` function has been called twice with both the expected electricity reader value and the expected water reader value. 

*A failure case*

```
  test "handle POST - with reader selection - one error on submit" do
    with_mock RestInserter,
      [post: fn reader ->
        case reader.id do
          "ElecReaderStateInput" -> {:ok, ""}
          "WaterReaderStateInput" -> {:error, "Error on submitting water reader!"}
        end
      end] do

      {500, err_msg} = ReaderSubmitPageController.post(@reader_data)
      assert String.contains?(err_msg, "Error on submitting water reader!")
      
      assert called RestInserter.post(@expected_elec_reader_value)
      assert called RestInserter.post(@expected_water_reader_value)
    end
  end
```

The failure test case is a bit more complex. Based on the reader value data that the `RestInserter` is called with we decide that the mock should return success for the electricity reader but should fail for the water reader.

Now, when calling the controllers post function we expect that to return an internal error (500) with the error message that we defined the `RestInserter` to return with.

And of course we also assert that the `RestInserter` was called twice.

Still pretty simple, isn't it?

#### The view

The view is responsible to render the HTML and convert that to a string to pass it back to the controller.

Similarly as for the controller we define a behaviour for this:

```
defmodule HouseStatUtil.View.View do
  @type string_result :: binary()
  
  @callback render(
    assigns :: %{binary() => any()}
  ) :: {:ok, string_result()} | {:error, string_result()}
end
```

This behaviour defines the `render/1` function along with input and output types. Erlang and Elixir are not statically typed but you can define types which are verified with dialyzer as an after compile process.

So the input for the `render/1` function defines `assigns` which ia a map of string -> anything entries. This map represents the model to be rendered.  
The result of `render/1` is a tuple of either `{:ok, string}` or `{:error, string}` where the 'string' is the rendered HTML.  
This is the contract for the render function.

##### Testing the view

Testing the view is even more simple than the controller because it is less likely that some collaborator must be mocked or faked here.  
As said earlier, classic MVC frameworks, also Phoenix, ASP MVC or [Play](https://www.playframework.com) mostly only allow to test rendered views for the existence of certain strings.  
This is insofar different in [Wicket](https://wicket.apache.org) that Wicket operates component based and keeps an abstract view representation in memory where it is possible to test the existence of components and certain model values rather than strings in the rendered output.

But any-who, here is an example of a simple test case that checks a heading in the rendered output:

```
  test "has form header" do
    {render_result, render_string} = render()

    assert render_result == :ok
    assert String.contains?(
      render_string,
      h2 do "Submit values to openHAB" end |> render_to_string()
    )
  end
```

As you can see the `render/1` function is called without model. This will not render the form components but certain other things that I know should be part of the HTML string. So we can check for it using a `String.contains?`.

You might realise that I've used some constructs that I will explain in the next chapter. For the string compare I create a `h2` HTML tag the same way as the view creates it and I want it to be part of the rendered view.

Here is another test case that checks for the rendered empty form:

```
  test "Render form components, empty reader inputs" do
    {render_result, render_string} = render()

    assert String.contains?(
      render_string,
      form action: "/submit_readers", method: "post" do
        input type: "submit", value: "Submit"
      end |> render_to_string
    )
  end
```

The empty form which contains the submit button only is created in the test and expected to be part of the rendered view. Similarly we can certainly pass in a proper model so that we have some reader value entry text fields and all that being rendered.

Creating those HTML tags using Elixir language constructs is pretty slick, isn't it? I'll talk about this now.

### How do to the HTML rendering

Let me start with this. I know Phoenix uses [EEx](https://hexdocs.pm/eex/EEx.html), the default templating library of Elixir (EEx stands for 'Embedded Elixir'). But, I do prefer (for this little project at least) to create HTML content in Elixir source code as language constructs, a DSL.

Taking the form example from above I want to create HTML like this:

```
form action: "/submit_readers", method: "post" do
  input type: "checkbox", name: "selected_" <> to_string(reader.tag)
  input type: "submit", value: "Submit"
end
```
... and so forth. This is pretty cool and just Elixir language.


##### Abstracting tags and attributes - creating a HTML DSL

No matter what backend generates the HTML I want to be flexible. With only a few macros we can create our own DSL that acts as a frontend that lets us use Elixir language constructs to write HTML code.

In the backend this little project uses [Eml](https://github.com/zambal/eml) to actually generate the HTML representation and the to_string conversion.  
However, it would be possible to also create an implementation that uses EEx as a backend. And we could switch the backend without changing the view because the API the view uses is an abstraction.

So here is what we have to do to create a HTML DSL.

First we need a collection of tags. I have hardcoded them into a list:

```
  @tags [:html, :head, :title, :base, :link, :meta, :style,
         :script, :noscript, :body, :div, :span, :article, ...]
```

Then I want to allow to define tags in two styles. A one-liner style and a style with a multi-line body to be able to express multiple child elements.

```
# one-liner
span id: "1", class: "span-class", do: "my span text"

# multi-liner
div id: "1", class: "div-class" do
  span do: "my span text"
  span do: "my second text"
end
```
We need two macros for this. The `do:` in the one-liner is seen just as an attribute to the macro. So we have to strip out the `do:` attribute and use it as body. The macro for this looks like this:

```
  defmacro tag(name, attrs \\ []) do
    {inner, attrs} = Keyword.pop(attrs, :do)
    quote do: HouseStatUtil.HTML.tag(unquote(name), unquote(attrs), do: unquote(inner))
  end
```
First we extract the value for the `:do` key in the `attrs` list and then pass the `name`, the remaining `attrs` and the extracted body as `inner` to the actual macro which looks like this and does the whole thing.

```
  defmacro tag(name, attrs, do: inner) do
    parsed_inner = parse_inner_content(inner)
    
    quote do
      %E{tag: unquote(name),
         attrs: Enum.into(unquote(attrs), %{}),
         content: unquote(parsed_inner)}
    end
  end

  defp parse_inner_content({:__block__, _, items}), do: items
  defp parse_inner_content(inner), do: inner
```

Here we get the first glimpse of Eml (the `%E{}` in there is an Eml structure type to create HTML tags). The helper function is to differentiate between having an AST as inner block or non-AST elements. But I don't want to go into more detail here.  
Instead I recommend reading the book [Metaprogrammning Elixir](https://pragprog.com/book/cmelixir/metaprogramming-elixir) by Chris McCord which deals a lot with macros and explains how it works.

But something is still missing. We now have a `tag` macro. With this macro we can create HTML tags like this:

```
tag "span", id: "1", class: "class", do: "foo"
```

But that's not yet what we want. One step is missing. We have to create macros for each of the defined HTML tags. Remember the list of tags from above. Now we take this list and create macros from the atoms in the list like so:

```
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
```
This creates three macros for each tag. I.e. for `span` it creates: `span/0`, `span/1` and `span/2`. The first two are because the `attrs` are optional but Elixir creates two function signatures for it. The third is a version that has a `do` block.

With all this put together we can create HTML as Elixir language syntax.
Checkout the full [module source](https://github.com/mdbergmann/elixir_house_stat_util/blob/master/lib/house_stat_util/html.ex) in the github repo.

##### Testing the DSL

Of course we test this. This is a test case for a one-liner tag:

```
  test "single element with attributes" do
    elem = input(id: "some-id", name: "some-name", value: "some-value")
    |> render_to_string

    IO.inspect elem

    assert String.starts_with?(elem, "<input")
    assert String.contains?(elem, ~s(id="some-id"))
    assert String.contains?(elem, ~s(name="some-name"))
    assert String.contains?(elem, ~s(value="some-value"))
    assert String.ends_with?(elem, "/>")
  end
```

This should be backend agnostic. So no matter which backend generated the HTML we want to see the test pass.

Here is a test case with inner tags:

```
  test "multiple sub elements - container" do
    html_elem = html class: "foo" do
      head
      body class: "bar"
    end
    |> render_to_string

    IO.inspect html_elem

    assert String.ends_with?(html_elem, 
      ~s(<html class="foo"><head></head><body class="bar"></body></html>))
  end
```

The source file has more tests, but that should suffice as examples.

### Localisation

So the controller, view and HTML generation is quite different to how Phoenix does it. The localisation is again similar. Both just use the [gettext](https://hexdocs.pm/gettext/Gettext.html) module of Elixir.

The way this works is pretty simple. You just create a module in your sources that 'uses' `Gettext`.

```
defmodule HouseStatUtil.Gettext do
  use Gettext, otp_app: :elixir_house_stat_util
end
```

This new module acts like a gettext wrapper module for your project. You should import it anywhere where you want to use one of the gettext functions: `gettext/1`, `ngettext/3`, `dgettext/2` for example `gettext("some key")` searches for a string key of "some key" in the localisation files.  
The localisation files must be created using `mix` tool.

So the process is to use the gettext function in your code where needed and then call `mix gettext.extract` which then extracts the gettext keys used in the source code to localization resource files.  
There is a lot more info on that on that gettext web page. Check it out.


### Outlook and recap

Doing a simple web application framework from scratch is quite easy. If you want to do more by hand and want to have more control over how things work then that seems to be a viable way. However, the larger the web application gets the more  you have to carve out concepts which could after all compete with Phoenix. And then, it might be worth using Phoenix right away. In a professional context I would use Phoenix anyway. Because this project has gone though the major headaches already and is battle proven.  
Nonetheless this was a nice experience and exploration.
