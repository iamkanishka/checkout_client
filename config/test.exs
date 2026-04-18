import Config

config :checkout_client,
  prefix: "testpfx1",
  environment: :sandbox,
  secret_key: "sk_sbox_test",
  access_key_id: nil,
  access_key_secret: nil,
  max_retries: 0,
  retry_base_delay: 0,
  timeout: 5_000,
  recv_timeout: 5_000,
  pool_size: 2,
  pool_count: 1,
  log_level: :none
