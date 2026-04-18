defmodule CheckoutClient.Auth.TokenStore do
  @moduledoc """
  ETS-backed `GenServer` that caches and proactively refreshes OAuth 2.0 JWT tokens.

  ## Design

  - An ETS table (`:set`, `:protected`) enables O(1) concurrent reads without
    blocking the `GenServer` for every request.
  - The `GenServer` serialises all write operations (fetch, store, invalidate).
  - Tokens are refreshed proactively `@refresh_buffer_seconds` before expiry via
    `Process.send_after/3`, preventing any request from ever blocking on a fresh fetch.
  - Multiple merchants are keyed by `{prefix, environment}`.
  """

  use GenServer

  require Logger

  alias CheckoutClient.Config

  @behaviour CheckoutClient.Behaviours.Auth

  @refresh_buffer_seconds 90
  @retry_delay_ms 5_000
  @table __MODULE__

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Returns a valid Bearer token for the given config.

  Checks ETS first (O(1)). On miss, delegates to the `GenServer` to fetch
  and cache a fresh token from the OAuth server.
  """
  @impl CheckoutClient.Behaviours.Auth
  @spec get_token(Config.t()) :: {:ok, String.t()} | {:error, term()}
  def get_token(config) do
    key = cache_key(config)

    case ets_lookup(key) do
      {:ok, token} -> {:ok, token}
      :miss -> GenServer.call(__MODULE__, {:fetch, config, key}, 15_000)
    end
  end

  @doc "Force-invalidates the cached token for this config (called automatically on 401)."
  @impl CheckoutClient.Behaviours.Auth
  @spec invalidate(Config.t()) :: :ok
  def invalidate(config) do
    GenServer.cast(__MODULE__, {:invalidate, cache_key(config)})
  end

  # ---------------------------------------------------------------------------
  # GenServer callbacks
  # ---------------------------------------------------------------------------

  @impl GenServer
  def init(_) do
    :ets.new(@table, [:named_table, :set, :protected, {:read_concurrency, true}])
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:fetch, config, key}, _, state) do
    # Re-check ETS — another process may have populated it while this was queued.
    case ets_lookup(key) do
      {:ok, token} ->
        {:reply, {:ok, token}, state}

      :miss ->
        case fetch_token(config) do
          {:ok, token, expires_in} ->
            store_token(key, token, expires_in)
            schedule_refresh(key, config, expires_in)
            {:reply, {:ok, token}, state}

          {:error, reason} = error ->
            Logger.error("[CheckoutClient.TokenStore] Token fetch failed: #{inspect(reason)}")
            {:reply, error, state}
        end
    end
  end

  @impl GenServer
  def handle_cast({:invalidate, key}, state) do
    :ets.delete(@table, key)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:refresh, key, config}, state) do
    Logger.debug("[CheckoutClient.TokenStore] Proactive refresh for #{inspect(key)}")

    case fetch_token(config) do
      {:ok, token, expires_in} ->
        store_token(key, token, expires_in)
        schedule_refresh(key, config, expires_in)

      {:error, reason} ->
        Logger.warning(
          "[CheckoutClient.TokenStore] Proactive refresh failed: #{inspect(reason)}. " <>
            "Will retry in #{@retry_delay_ms}ms."
        )

        Process.send_after(self(), {:refresh, key, config}, @retry_delay_ms)
    end

    {:noreply, state}
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  @spec cache_key(Config.t()) :: {String.t(), atom()}
  defp cache_key(%{prefix: p, environment: e}), do: {p, e}

  @spec ets_lookup({String.t(), atom()}) :: {:ok, String.t()} | :miss
  defp ets_lookup(key) do
    now = System.monotonic_time(:second)

    case :ets.lookup(@table, key) do
      [{^key, token, expires_at}] when expires_at > now -> {:ok, token}
      _ -> :miss
    end
  end

  @spec store_token({String.t(), atom()}, String.t(), pos_integer()) :: true
  defp store_token(key, token, expires_in) do
    expires_at = System.monotonic_time(:second) + expires_in - @refresh_buffer_seconds
    :ets.insert(@table, {key, token, expires_at})
  end

  defp schedule_refresh(key, config, expires_in) do
    delay_ms = max((expires_in - @refresh_buffer_seconds) * 1_000, 1_000)
    Process.send_after(self(), {:refresh, key, config}, delay_ms)
  end

  @spec fetch_token(Config.t()) ::
          {:ok, String.t(), pos_integer()} | {:error, term()}
  defp fetch_token(config) do
    # Credo: replace unless/else with if/else for clarity
    if Config.oauth_configured?(config) do
      do_fetch_token(config)
    else
      {:error, :oauth_not_configured}
    end
  end

  @spec do_fetch_token(Config.t()) :: {:ok, String.t(), pos_integer()} | {:error, term()}
  defp do_fetch_token(config) do
    credentials = Base.encode64("#{config.access_key_id}:#{config.access_key_secret}")

    req_opts = [
      url: Config.auth_url(config),
      method: :post,
      headers: [
        {"authorization", "Basic #{credentials}"},
        {"content-type", "application/x-www-form-urlencoded"}
      ],
      body: "grant_type=client_credentials",
      finch: CheckoutClient.Finch,
      receive_timeout: config.recv_timeout,
      connect_options: build_connect_opts(config)
    ]

    case Req.request(req_opts) do
      {:ok, %Req.Response{status: 200, body: body}} when is_map(body) ->
        {:ok, body["access_token"], body["expires_in"] || 3_600}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:token_request_failed, status, body}}

      {:error, reason} ->
        {:error, {:http_error, reason}}
    end
  end

  @spec build_connect_opts(Config.t()) :: keyword()
  defp build_connect_opts(%{mtls: false, timeout: t}), do: [timeout: t]

  defp build_connect_opts(%{mtls: true, timeout: t, mtls_cert: cert, mtls_key: key} = cfg) do
    ssl =
      [certfile: cert, keyfile: key, verify: :verify_peer]
      |> then(fn o ->
        if cfg[:mtls_cacert], do: [{:cacertfile, cfg.mtls_cacert} | o], else: o
      end)

    [timeout: t, transport_opts: ssl]
  end
end
