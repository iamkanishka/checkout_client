defmodule CheckoutClient.Telemetry do
  @moduledoc """
  Telemetry integration for `CheckoutClient`.

  ## Events

  All events share the prefix configured via `telemetry_prefix` (default
  `[:checkout_client, :request]`).

  | Suffix | When emitted |
  |---|---|
  | `:start` | Before the HTTP request is sent |
  | `:stop` | After any HTTP response is received |
  | `:exception` | On network error, timeout, or unexpected failure |

  ## Measurements

  | Key | Unit | Events |
  |---|---|---|
  | `:system_time` | native | `:start` |
  | `:duration` | native | `:stop`, `:exception` |

  ## Metadata

  | Key | `:start` | `:stop` | `:exception` |
  |---|---|---|---|
  | `:method` | ✓ | ✓ | ✓ |
  | `:path` | ✓ | ✓ | ✓ |
  | `:full_url` | ✓ | ✓ | ✓ |
  | `:environment` | ✓ | ✓ | ✓ |
  | `:prefix` | ✓ | ✓ | ✓ |
  | `:status` | — | ✓ | — |
  | `:request_id` | — | ✓ | — |
  | `:idempotency_key` | — | ✓ | — |
  | `:error_codes` | — | ✓ | — |
  | `:reason` | — | — | ✓ |

  ## Attaching handlers

      :telemetry.attach_many(
        "my-app-checkout",
        CheckoutClient.Telemetry.events(),
        &MyApp.handle_checkout_event/4,
        nil
      )
  """

  require Logger

  @typedoc "Bundled stop-event metadata, used internally to keep arity ≤ 8."
  @type stop_meta :: %{
          path: String.t(),
          method: atom(),
          full_url: String.t(),
          status: non_neg_integer(),
          request_id: String.t() | nil,
          idempotency_key: String.t() | nil,
          error_codes: [String.t()]
        }

  @doc "Returns all telemetry events emitted by `CheckoutClient`."
  # nonempty_list because we always return exactly 3 elements.
  @dialyzer {:nowarn_function, events: 0}
  @spec events() :: [[atom()]]
  def events do
    [
      [:checkout_client, :request, :start],
      [:checkout_client, :request, :stop],
      [:checkout_client, :request, :exception]
    ]
  end

  @doc false
  @spec emit_start(String.t(), atom(), String.t(), map()) :: :ok
  def emit_start(path, method, full_url, config) do
    prefix = Map.get(config, :telemetry_prefix, [:checkout_client, :request])

    :telemetry.execute(
      prefix ++ [:start],
      %{system_time: System.system_time()},
      %{
        method: method,
        path: path,
        full_url: full_url,
        environment: config.environment,
        prefix: config.prefix
      }
    )
  end

  @doc """
  Emits a `:stop` telemetry event.

  Accepts a `stop_meta()` map bundling path/method/url/status/ids to keep
  the public arity at 3 and satisfy Credo's 8-parameter limit.

  ## Example

      CheckoutClient.Telemetry.emit_stop(
        %{
          path: "/payments",
          method: :post,
          full_url: "https://...",
          status: 201,
          request_id: "req_abc",
          idempotency_key: "uuid",
          error_codes: []
        },
        config,
        duration
      )
  """
  @spec emit_stop(stop_meta(), map(), integer()) :: :ok
  def emit_stop(meta, config, duration) do
    event_prefix = Map.get(config, :telemetry_prefix, [:checkout_client, :request])

    :telemetry.execute(
      event_prefix ++ [:stop],
      %{duration: duration},
      %{
        method: meta.method,
        path: meta.path,
        full_url: meta.full_url,
        status: meta.status,
        request_id: meta.request_id,
        idempotency_key: meta.idempotency_key,
        error_codes: meta.error_codes,
        environment: config.environment,
        prefix: config.prefix
      }
    )
  end

  @doc false
  @spec emit_exception(String.t(), atom(), String.t(), term(), map(), integer()) :: :ok
  def emit_exception(path, method, full_url, reason, config, duration) do
    event_prefix = Map.get(config, :telemetry_prefix, [:checkout_client, :request])

    :telemetry.execute(
      event_prefix ++ [:exception],
      %{duration: duration},
      %{
        method: method,
        path: path,
        full_url: full_url,
        reason: reason,
        environment: config.environment,
        prefix: config.prefix
      }
    )

    do_log(config)
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  @spec do_log(map()) :: :ok
  defp do_log(%{log_level: :none}), do: :ok

  defp do_log(config) do
    level = Map.get(config, :log_level, :warning)
    Logger.log(level, "[CheckoutClient] Request exception occurred")
  end
end
