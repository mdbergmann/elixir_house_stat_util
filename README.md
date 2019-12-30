# HouseStatUtil

This is my first Elixir appplication.

It is only used for me internally to submit reader/meter values that I read and note manually, like electricity, water, etc.

This tool provides a web interface to enter and submit those values to a running openHAB instance.

The avilable reader/meter and openHAB items are hard-coded right now. Maybe I'll make this configurable at some point.

I started with the [Phoenix framework](https://www.phoenixframework.org) but since it was a lot new stuff and it wasn't really easily possible to understand much of the internal working I decided to build on the Elixir Plugs, which are also used in Phoenix.

So I have basically built a small MVC framework with controllers and views and support for internationalization.
The views are based on the [Eml framework](https://github.com/zambal/eml) that allows to write HTML as Elixir code. However, to be more flexible I've added an abstraction layer in front of it so that I could switch to EEx templating (which is used in Phoenix) easily.

This tool was completely developed using Emacs, the Elixir-mode and the [ElixirLS](https://github.com/elixir-lsp/elixir-ls) language server.
This worked out pretty well mostly.
