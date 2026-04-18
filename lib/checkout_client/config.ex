defmodule CheckoutClient.Config do
  @moduledoc """
  Configuration management for `CheckoutClient`.

  All options are validated at startup via `NimbleOptions`.
  Provide secrets exclusively through environment variables in `config/runtime.exs`.

  ## Required

  - `:prefix` — first 8 characters of your `client_id`, excluding the `cli_` prefix.
    Find it at Dashboard → Settings → Account details → Connection settings.

  ## Authentication (provide at least one)

  - `:access_key_id` + `:access_key_secret` — OAuth 2.0 (recommended)
  - `:secret_key` — static secret key fallback
  - `:public_key` — client-side tokenization only

  ## Example

      # config/runtime.exs
      config :checkout_client,
        prefix:            System.fetch_env!("CHECKOUT_PREFIX"),
        access_key_id:     System.get_env("CHECKOUT_ACCESS_KEY_ID"),
        access_key_secret: System.get_env("CHECKOUT_ACCESS_KEY_SECRET"),
        environment:       :production
  """

  @schema NimbleOptions.new!([
            {:prefix,
             [
               type: :string,
               required: true,
               doc: "First 8 chars of client_id excluding cli_ prefix."
             ]},
            {:environment,
             [
               type: {:in, [:production, :sandbox]},
               default: :production,
               doc: "`:production` or `:sandbox`."
             ]},
            {:access_key_id,
             [
               type: {:or, [:string, nil]},
               default: nil,
               doc: "OAuth 2.0 access key ID (`ack_...`)."
             ]},
            {:access_key_secret,
             [
               type: {:or, [:string, nil]},
               default: nil,
               doc: "OAuth 2.0 access key secret."
             ]},
            {:secret_key,
             [
               type: {:or, [:string, nil]},
               default: nil,
               doc: "Static secret API key (`sk_...`)."
             ]},
            {:public_key,
             [
               type: {:or, [:string, nil]},
               default: nil,
               doc: "Public key (`pk_...`) for client-side tokenization."
             ]},
            {:private_link,
             [
               type: :boolean,
               default: false,
               doc: "Use AWS PrivateLink base URLs (`pl-{prefix}.api.checkout.com`)."
             ]},
            {:mtls,
             [
               type: :boolean,
               default: false,
               doc: "Enable mutual TLS. Requires `mtls_cert` and `mtls_key`."
             ]},
            {:mtls_cert,
             [
               type: {:or, [:string, nil]},
               default: nil,
               doc: "Path to the client TLS certificate PEM file."
             ]},
            {:mtls_key,
             [
               type: {:or, [:string, nil]},
               default: nil,
               doc: "Path to the client TLS private key PEM file."
             ]},
            {:mtls_cacert,
             [
               type: {:or, [:string, nil]},
               default: nil,
               doc: "Path to the CA certificate bundle PEM file."
             ]},
            {:timeout,
             [type: :pos_integer, default: 30_000, doc: "Connect timeout in milliseconds."]},
            {:recv_timeout,
             [
               type: :pos_integer,
               default: 30_000,
               doc: "Response receive timeout in milliseconds."
             ]},
            {:pool_size,
             [type: :pos_integer, default: 10, doc: "Finch connection pool size per host."]},
            {:pool_count, [type: :pos_integer, default: 1, doc: "Number of Finch pools per host."]},
            {:max_retries,
             [
               type: :non_neg_integer,
               default: 3,
               doc: "Max retries on 429/5xx. Set to 0 to disable."
             ]},
            {:retry_base_delay,
             [type: :pos_integer, default: 500, doc: "Base retry delay in milliseconds."]},
            {:retry_max_delay,
             [type: :pos_integer, default: 30_000, doc: "Maximum retry delay cap in milliseconds."]},
            {:idempotency_key_prefix,
             [
               type: {:or, [:string, nil]},
               default: nil,
               doc: "Optional prefix prepended to auto-generated idempotency keys."
             ]},
            {:user_agent,
             [
               type: :string,
               default: "checkout_client/#{Mix.Project.config()[:version] || "dev"}",
               doc: "User-Agent header sent with every request."
             ]},
            {:log_level,
             [
               type: {:in, [:debug, :info, :warning, :error, :none]},
               default: :info,
               doc: "Log level for request/response logging. `:none` disables all logging."
             ]},
            {:telemetry_prefix,
             [
               type: {:list, :atom},
               default: [:checkout_client, :request],
               doc: "Telemetry event name prefix."
             ]}
          ])

  @type t :: %{
          prefix: String.t(),
          environment: :production | :sandbox,
          access_key_id: String.t() | nil,
          access_key_secret: String.t() | nil,
          secret_key: String.t() | nil,
          public_key: String.t() | nil,
          private_link: boolean(),
          mtls: boolean(),
          mtls_cert: String.t() | nil,
          mtls_key: String.t() | nil,
          mtls_cacert: String.t() | nil,
          timeout: pos_integer(),
          recv_timeout: pos_integer(),
          pool_size: pos_integer(),
          pool_count: pos_integer(),
          max_retries: non_neg_integer(),
          retry_base_delay: pos_integer(),
          retry_max_delay: pos_integer(),
          idempotency_key_prefix: String.t() | nil,
          user_agent: String.t(),
          log_level: :debug | :info | :warning | :error | :none,
          telemetry_prefix: [atom()]
        }

  @doc """
  Validates and resolves configuration from `Application.get_all_env(:checkout_client)`
  merged with keyword `overrides`.

  Raises `NimbleOptions.ValidationError` on invalid options.
  Raises `ArgumentError` when no authentication credentials are configured.
  """
  @spec resolve(keyword()) :: t()
  def resolve(overrides \\ []) do
    Application.get_all_env(:checkout_client)
    |> Keyword.merge(overrides)
    |> NimbleOptions.validate!(@schema)
    |> Map.new()
    |> validate_auth!()
  end

  @doc """
  Returns the API base URL for the given config.

      iex> CheckoutClient.Config.api_base_url(%{environment: :production, prefix: "abcd1234", private_link: false})
      "https://abcd1234.api.checkout.com"
  """
  @spec api_base_url(t()) :: String.t()
  def api_base_url(%{environment: env, prefix: prefix, private_link: pl}) do
    link_prefix = if pl, do: "pl-", else: ""

    case env do
      :production -> "https://#{link_prefix}#{prefix}.api.checkout.com"
      :sandbox -> "https://#{link_prefix}#{prefix}.api.sandbox.checkout.com"
    end
  end

  @doc """
  Returns the OAuth token endpoint URL for the given config.

      iex> CheckoutClient.Config.auth_url(%{environment: :production, prefix: "abcd1234"})
      "https://abcd1234.access.checkout.com/connect/token"
  """
  @spec auth_url(t()) :: String.t()
  def auth_url(%{environment: :production, prefix: prefix}),
    do: "https://#{prefix}.access.checkout.com/connect/token"

  def auth_url(%{environment: :sandbox, prefix: prefix}),
    do: "https://#{prefix}.access.sandbox.checkout.com/connect/token"

  @doc "Returns `true` when both OAuth credentials are non-nil strings."
  @spec oauth_configured?(t()) :: boolean()
  def oauth_configured?(%{access_key_id: id, access_key_secret: secret}),
    do: is_binary(id) and is_binary(secret)

  @doc "Returns `true` when a static secret key is configured."
  @spec secret_key_configured?(t()) :: boolean()
  def secret_key_configured?(%{secret_key: sk}), do: is_binary(sk)

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  @spec validate_auth!(t()) :: t()
  defp validate_auth!(config) do
    unless oauth_configured?(config) or secret_key_configured?(config) or
             is_binary(config[:public_key]) do
      raise ArgumentError, """
      [CheckoutClient] No authentication credentials configured. Provide one of:
        - access_key_id + access_key_secret  (OAuth 2.0 — recommended)
        - secret_key                          (static secret key)
        - public_key                          (client-side only)
      """
    end

    if config.mtls and is_nil(config.mtls_cert) do
      raise ArgumentError,
            "[CheckoutClient] `mtls: true` requires `mtls_cert` to be set."
    end

    config
  end
end
