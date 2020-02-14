import Config

config :elixir_house_stat_util,
  :openhab_base_url, "http://localhost:8080/rest/items/" #"http://mini.mabe.private:8080/rest/items/"

config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]
