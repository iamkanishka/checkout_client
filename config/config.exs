import Config

config :checkout_client,
  prefix: System.get_env("CHECKOUT_PREFIX"),
  access_key_id: System.get_env("CHECKOUT_ACCESS_KEY_ID"),
  access_key_secret: System.get_env("CHECKOUT_ACCESS_KEY_SECRET"),
  secret_key: System.get_env("CHECKOUT_SECRET_KEY"),
  environment: :sandbox,
  timeout: 30_000,
  recv_timeout: 30_000,
  pool_size: 10,
  pool_count: 1,
  max_retries: 3,
  retry_base_delay: 500,
  retry_max_delay: 30_000,
  log_level: :info,
  private_link: false,
  mtls: false

import_config "#{config_env()}.exs"
