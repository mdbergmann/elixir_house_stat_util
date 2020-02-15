# Developing a simple MVC framework in Elixir

I did explore [Elixir](https://elixir-lang.org) in the last half year.  
It's a fantastic language. Relatively young but already mature. It runs on the solid and battle proven Erlang VM.

Now I thought it is time to have a look at the web framework [Phoenix](https://www.phoenixframework.org).

After reading a few things and doing some tutorials I didn't really understand what's going on underneath this abstraction that Phoenix has built. There seemed to be a lot of magic happening. So I wanted to understand that first.

Of course a lot of briliant work has gone into Phoenix. However, for some key components like the web server, the request routing, the template library Phoenix more or less just does the glueing.

But for me it was important to understand how the web server is integrated, and how defining routes and handlers work.  
So the result of this exploration was a simple MVC web framework.  

It is actually quite easy to develop something simple from scratch. Of course this cannot compete with Phoenix and it should not.  
However for simple web pages this might be fully sufficient and it doesn't require a large technology stack.

So I'd like to go though this step by step while crafting the code as we go. The web application will contain a simple form where I want to put in reader values of my house, like electricity or water. When those are submitted they are transmitted to my [openHAB](https://www.openhab.org) system. So you might see the name 'HouseStatUtil' more often. This is the name of the project.

Those are the components we have a look at:

- the web server
- the request routing and how to define routes
- how to add controllers and views and the model they use
- the HTML rendering
- string resource localization

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
- [Eml](https://github.com/zambal/eml): is a library for generating HTML in form of Elixir language constucts, a DSL. But as we will later see, Elixir macros are very powerful (almost as Common Lisp macros). We we will build our own HTML DSL abstraction which should make it easy to use any backend library to generate HTML.
- [gettext](https://hexdocs.pm/gettext/Gettext.html): is the default localization framework in Elixir. We will see later how that works.
- [mock](https://github.com/jjh42/mock): since we do Test-Driven Development (TDD) of course we need a mocking framework. A library for unit tests is not necessary. This is part of the core Elixir. 

### The web server

[Cowboy](https://ninenines.eu) is probably the most well known and used web server in the Erlang world. But we don't have to deal with the details that much.

But we have to tell the Erlang runtime to start Cowboy as a separate 'application' in the VM. The term 'application' is a bit misleading. You should see this more as a module, or component.

Since in Erlang most things are actor based, and you can have a hierarchy and eventually a tree of actors that are spawned in an 'application' (or component) you have to at least make sure that those components are up and running before you use them.

So we'll have to add this to `application.ex` which is you application entry point and should be inside the 'lib/<projectname>' folder.

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

The `start` function is called by the runtime. Now we have to define the 'children' applications we want to have started. Here we define the `Plug.Cowboy` as a child.

The line `plug: HouseStatUtil.Router` defines the request router. Well have a look at this later.

`Supervisor.start_link(children, opts)` will then start the application(s) as separate actors/processes.


### Request routing and how to define routes

The `HouseStatUtil.Router` is the next step. So we need to tell Cowboy how to deal with requests that come in. In  ost web applications you have to define some routing, or define page beans that are mapped to some request paths.

In Elixir this is pretty slick. The language allows to call functions without parentheses like so:

```
get "/" do
	# do someting
end
```

This could be written like as as well: `get("/") do`

This almost looks like a DSL, but it isn't. Those are normal function calls.

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

`use Plug.Router` is the key element here. This will make this module a router. This also specifies the routing definitions with `get`, `post` and so on.  

`conn` is a connection structure which has all the data about the connection and the request, like the header and query paremeters and so on. `conn.params` is a combination of POST and query parameters.

Each route definition must send a response to the client. This is done with `send_resp`. It does take three parameters, the connection structure, a status and a response body (which is the payload). 

All the `plug` definitions are executed in a chain for each request. Which means every request is url encoded (the request path at least) and must have a content-type of 'text/*'.

`plug :match` does the matching on the paths. The last `match _ do` is a 'catch all' match which here sends a 404 error back to the client.

As you can see we have two routes. Each route is handled by a view controller. The only thing we pass to the view controller is the connection parameters.

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

    IO.inspect conn

    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "Submit values to openHAB")
  end

  test "post on /submit_readers" do
    conn = :post
    |> conn("/submit_readers")
    |> Router.call(@opts)

    IO.inspect conn

    assert conn.state == :sent
    assert conn.status == 200
  end
end
``` 

There is a bit of magic that is being done by the `Plug.Test`. It allows you to specify the `:get` and `:post` requests as in the tests.

After the `Router.call` has been made we can inspect the `conn` structure and assert on various things. For the `conn.resp_body` we only have a chance to assert on some existing string in the HTML output.

This can be done better. A good example is [Apache Wicket](https://wicket.apache.org), a Java based web framework that has excelent testing capabilities.

Next step are the view controllers.


### How to define controllers and views and the model

#### The view controller

As you have seen above, each route uses it's own view controller. I thought that a view controller can handle `get` or `post` requests on a route. So that handling more 'views' related to a path can be combined in a view controller.
But you can do that as you wish. There is no rule.

As a first step I defined a `behavior` for a view controller. It looks like this:

```
defmodule HouseStatUtil.ViewController.Controller do
  @callback get(params :: %{binary() => any()}) :: {integer(), binary()}
  @callback post(params :: %{binary() => any()}) :: {integer(), binary()}
end
```

It defines two funtions whos parameters are 'spec'ed as a map of strings -> anything (`binary()` is Erlang and is  actually something stringlike. I could also use an Elixir `string` here). And those functions return a tuple of integer (the status) and again a string (the response body).

I thought that the controller should actually define the status since it has to deal with the logic to render the view and process the form parameters, maybe call some backend or collaborator. So if anything goes wrong there the controller knows it.

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
Even though `post` is not allowed for this controller and just returns error 400.

The `get` function is the important thing here. The response body for `get` is generated by the views `render()` function. So we have a view definition here imported as `ReaderPageView` which specifies a `render()` function.

The views `render()` function takes a model (a map) where we here just specify some `:reader_input` definitions. Those are later rendered as a table with checkbox, label and textfield.

The `render()` function returns a tuple of `{[ok|error], body}`. In case of `:ok` we return a success response (200) with the rendered body.

So we already have the model in the play here that is used by both controller and view. In this case the controller creates the model that shouold be used by the view to render.

##### Generating HTML in the controller

For simple responses it's not absolutely necessary to actually specify a view. The controller can easily generate simple HTML and just return it. However, it should stay simple and short to not clutter the controller source code. After all it's the views responsibility to do that.

##### A view controller with submit

To support a submit you certainly have to implement the `post` function. The `post` function in the controller will receive the form parameters as a map of tuples. This is how it looks like:

```
%{
  "reader_value_chip" => "",
  "reader_value_elec" => "17917.3",
  "reader_value_water" => "",
  "selected_elec" => "on"
}
```

The keys of the map are the 'name' attributes of the form components.

Since we only want to send selected reader values to openHAB we have to filter the form parameter map for those that  were selected, which here is only the electricity reader ('reader_value_elec').

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

More sophisticated frameworks like Phoenix do some pre-processing and deliver the form parameters in pre-defined or standardized structure types.  
We don't have that, so there might be a bit of manual parsing required. But we're developers, right?

##### Testing the controller

Since the controller is just a simple module it should be easy to test it. Of course it depends on the dependencies of your controller. At least the controller depends on a view component where a `render()` function is called with some model.

But the controller test shouldn't test the rendering of the view. We basically just test a bi-directional pass through here. One direction is the generated model to the views `render()` function, and the other direction is the views `render()` result that should be mapped to a controller result.

To avoid to really have the view render stuff in the controller test we can mock the views `render()` function.

In my case here I have a trivial test

This is easy using the `mock` library.


#### The view

### How do to the HTML rendering

### Localization



