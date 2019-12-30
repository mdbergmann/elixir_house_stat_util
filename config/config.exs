import Config

config :elixir_house_stat_util,
  :openhab_base_url, "http://localhost:8080/rest/items/" #"http://mini.mabe.private:8080/rest/items/"

config :logger,
  compile_time_purge_level: :debug
