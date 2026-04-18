defmodule CheckoutClient.Client do
  @moduledoc """
  Central HTTP dispatcher for all Checkout.com API requests.

  Handles authentication, idempotency key injection, retry, logging, telemetry,
  and structured error wrapping. All resource modules delegate here.
  """

  require Logger

  alias CheckoutClient.{Auth, Config, Error, Telemetry}
  alias CheckoutClient.HTTP.{Idempotency, Retry}

  @behaviour CheckoutClient.Behaviours.HTTP

  @type result :: {:ok, map() | nil} | {:error, Error.t()}

  # Req >= 0.5 headers are %{String.t() => [String.t()]} — not a keyword list.
  @typep req_headers :: %{String.t() => [String.t()]}

  @typep req_response :: %Req.Response{
           status: non_neg_integer(),
           headers: req_headers(),
           body: term(),
           private: map(),
           trailers: map()
         }

  @doc "Perform a GET request."
  @spec get(String.t(), keyword()) :: result()
  def get(path, opts \\ []), do: request(:get, path, nil, opts)

  @doc "Perform a POST request."
  @spec post(String.t(), map() | nil, keyword()) :: result()
  def post(path, body \\ nil, opts \\ []), do: request(:post, path, body, opts)

  @doc "Perform a PUT request."
  @spec put(String.t(), map(), keyword()) :: result()
  def put(path, body, opts \\ []), do: request(:put, path, body, opts)

  @doc "Perform a PATCH request."
  @spec patch(String.t(), map(), keyword()) :: result()
  def patch(path, body, opts \\ []), do: request(:patch, path, body, opts)

  @doc "Perform a DELETE request."
  @spec delete(String.t(), keyword()) :: result()
  def delete(path, opts \\ []), do: request(:delete, path, nil, opts)

  @impl CheckoutClient.Behaviours.HTTP
  def request(method, path, body, opts) do
    config = resolve_config(opts)
    t0 = System.monotonic_time()
    full_url = Config.api_base_url(config) <> path
    idempotency_key = Idempotency.resolve(method, path, [{:_config, config} | opts])

    Telemetry.emit_start(path, method, full_url, config)
    log_request(method, full_url, config)

    with {:ok, auth_header} <- Auth.resolve(config),
         {:ok, response} <- execute(method, full_url, body, auth_header, idempotency_key, config) do
      duration = System.monotonic_time() - t0
      request_id = header_value(response.headers, "cko-request-id")
      error_codes = extract_error_codes(response.body)

      stop_meta = %{
        path: path,
        method: method,
        full_url: full_url,
        status: response.status,
        request_id: request_id,
        idempotency_key: idempotency_key,
        error_codes: error_codes
      }

      Telemetry.emit_stop(stop_meta, config, duration)
      log_response(response.status, config)
      parse_response(response, idempotency_key)
    else
      {:error, reason} ->
        duration = System.monotonic_time() - t0
        err = wrap_error(reason)
        Telemetry.emit_exception(path, method, full_url, err, config, duration)
        {:error, err}
    end
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  @spec execute(
          atom(),
          String.t(),
          map() | nil,
          String.t(),
          String.t() | nil,
          Config.t()
        ) :: {:ok, req_response()} | {:error, term()}
  defp execute(method, full_url, body, auth_header, idempotency_key, config) do
    headers = build_headers(auth_header, idempotency_key, config)

    req_opts =
      [
        method: method,
        url: full_url,
        headers: headers,
        finch: CheckoutClient.Finch,
        receive_timeout: config.recv_timeout,
        connect_options: build_connect_opts(config)
      ]
      |> put_body(body)
      |> Keyword.merge(Retry.req_opts(config))

    case Req.request(req_opts) do
      {:ok, %Req.Response{status: 401}} = result ->
        # Invalidate cached token and retry once with a fresh one.
        Auth.invalidate(config)

        case Auth.resolve(config) do
          {:ok, new_auth} ->
            new_headers = build_headers(new_auth, idempotency_key, config)
            Req.request(Keyword.put(req_opts, :headers, new_headers))

          _ ->
            result
        end

      other ->
        other
    end
  end

  @spec build_headers(String.t(), String.t() | nil, Config.t()) :: [{String.t(), String.t()}]
  defp build_headers(auth_header, idempotency_key, config) do
    base = [
      {"authorization", auth_header},
      {"content-type", "application/json"},
      {"accept", "application/json"},
      {"user-agent", config.user_agent}
    ]

    if idempotency_key do
      [{"cko-idempotency-key", idempotency_key} | base]
    else
      base
    end
  end

  # Dialyzer success typing shows the return is always a non-empty list of
  # {:timeout, pos_integer()} | {:transport_opts, [any(), ...]} tuples.
  # Use `[keyword()]` (list of any keyword pairs) to avoid contract_supertype.
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

  @spec put_body(keyword(), map() | nil) :: keyword()
  defp put_body(opts, nil), do: opts
  defp put_body(opts, body), do: Keyword.put(opts, :json, body)

  @spec parse_response(req_response(), String.t() | nil) :: result()
  defp parse_response(%Req.Response{status: s, body: body}, _) when s in 200..299,
    do: {:ok, body}

  defp parse_response(%Req.Response{status: s, body: body, headers: headers}, key),
    do: {:error, Error.from_response(s, body, headers_to_list(headers), key)}

  @spec resolve_config(keyword()) :: Config.t()
  defp resolve_config(opts) do
    case Keyword.get(opts, :client) do
      %{config: config} ->
        config

      nil ->
        overrides =
          Keyword.take(opts, [
            :idempotency_key,
            :timeout,
            :recv_timeout,
            :max_retries,
            :secret_key,
            :access_key_id,
            :access_key_secret,
            :prefix,
            :environment
          ])

        Config.resolve(overrides)
    end
  end

  @spec wrap_error(term()) :: Error.t()
  defp wrap_error(:no_auth_credentials),
    do: Error.new(:auth_error, "No authentication credentials configured")

  defp wrap_error(%Error{} = err), do: err
  defp wrap_error(reason), do: Error.network_error(reason)

  # Req.Response.headers is always %{String.t() => [String.t()]} — never a list.
  # Dialyzer flags the is_list guard as dead code. We keep only the map path.
  @spec headers_to_list(req_headers()) :: [{String.t(), String.t()}]
  defp headers_to_list(headers) do
    Enum.flat_map(headers, fn {name, values} ->
      Enum.map(values, fn v -> {name, v} end)
    end)
  end

  # Same: Req.Response.headers is always a map — only the map clause is reachable.
  @spec header_value(req_headers(), String.t()) :: String.t() | nil
  defp header_value(headers, name) do
    case Map.get(headers, name) do
      [value | _] -> value
      _ -> nil
    end
  end

  @spec extract_error_codes(term()) :: [String.t()]
  defp extract_error_codes(body) when is_map(body),
    do: Map.get(body, "error_codes", [])

  defp extract_error_codes(_), do: []

  defp log_request(_, _, %{log_level: :none}), do: :ok

  defp log_request(method, url, %{log_level: level}) do
    Logger.log(level, "[CheckoutClient] → #{String.upcase(to_string(method))} #{url}")
  end

  defp log_response(_, %{log_level: :none}), do: :ok

  defp log_response(status, %{log_level: level}) do
    Logger.log(level, "[CheckoutClient] ← HTTP #{status}")
  end
end
