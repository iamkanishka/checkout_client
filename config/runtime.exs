import Config

if config_env() == :prod do
  prefix =
    System.get_env("CHECKOUT_PREFIX") ||
      raise """
      CHECKOUT_PREFIX is required in production.
      Set it to the first 8 characters of your client_id (excluding the cli_ prefix).
      Find it: Dashboard → Settings → Account details → Connection settings.
      """

  config :checkout_client,
    prefix: prefix,
    environment: :production,
    access_key_id: System.get_env("CHECKOUT_ACCESS_KEY_ID"),
    access_key_secret: System.get_env("CHECKOUT_ACCESS_KEY_SECRET"),
    secret_key: System.get_env("CHECKOUT_SECRET_KEY"),
    private_link: System.get_env("CHECKOUT_PRIVATE_LINK", "false") == "true",
    mtls: System.get_env("CHECKOUT_MTLS_ENABLED", "false") == "true",
    mtls_cert: System.get_env("CHECKOUT_MTLS_CERT"),
    mtls_key: System.get_env("CHECKOUT_MTLS_KEY"),
    mtls_cacert: System.get_env("CHECKOUT_MTLS_CACERT"),
    pool_size: String.to_integer(System.get_env("CHECKOUT_POOL_SIZE", "25")),
    pool_count: String.to_integer(System.get_env("CHECKOUT_POOL_COUNT", "2")),
    max_retries: String.to_integer(System.get_env("CHECKOUT_MAX_RETRIES", "3")),
    timeout: String.to_integer(System.get_env("CHECKOUT_TIMEOUT_MS", "30000")),
    recv_timeout: String.to_integer(System.get_env("CHECKOUT_RECV_TIMEOUT_MS", "30000")),
    log_level: String.to_existing_atom(System.get_env("CHECKOUT_LOG_LEVEL", "warning"))
end
