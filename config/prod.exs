import Config

config :checkout_client,
  environment: :production,
  pool_size: 25,
  pool_count: 2,
  max_retries: 3,
  retry_base_delay: 500,
  log_level: :warning
