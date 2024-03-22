import Config


config :finch, finch_config:
  [connect_options: [
    transport_opts: [
      cacertfile: "priv/cacerts.pem"
    ]
  ]]
