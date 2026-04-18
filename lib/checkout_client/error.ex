defmodule CheckoutClient.Error do
  @moduledoc """
  Structured error returned by all `CheckoutClient` API functions.

  Implements `Exception` so it works with `raise/1` and `rescue`.

  ## Pattern matching

      case CheckoutClient.Payments.capture(id) do
        {:ok, result} -> handle(result)
        {:error, %CheckoutClient.Error{type: :not_found}} -> handle_missing()
        {:error, %CheckoutClient.Error{type: :rate_limited}} -> schedule_retry()
        {:error, %CheckoutClient.Error{type: :validation_error, error_codes: codes}} ->
          handle_validation(codes)
        {:error, %CheckoutClient.Error{} = err} ->
          Logger.error(Exception.message(err))
      end
  """

  @type error_kind ::
          :validation_error
          | :auth_error
          | :not_found
          | :conflict
          | :rate_limited
          | :server_error
          | :network_error
          | :api_error

  @type t :: %__MODULE__{
          type: error_kind(),
          status: non_neg_integer() | nil,
          request_id: String.t() | nil,
          idempotency_key: String.t() | nil,
          error_type: String.t() | nil,
          error_codes: [String.t()],
          message: String.t(),
          raw: map() | nil
        }

  defexception type: :api_error,
               status: nil,
               request_id: nil,
               idempotency_key: nil,
               error_type: nil,
               error_codes: [],
               message: "Unknown Checkout.com API error",
               raw: nil

  @impl Exception
  def message(%__MODULE__{} = err) do
    base = err.message
    status_part = if err.status, do: " (HTTP #{err.status})", else: ""

    codes_part =
      if err.error_codes != [], do: " codes=#{Enum.join(err.error_codes, ",")}", else: ""

    rid_part = if err.request_id, do: " request_id=#{err.request_id}", else: ""
    base <> status_part <> codes_part <> rid_part
  end

  @doc "Build an `Error` from an HTTP response."
  @spec from_response(non_neg_integer(), term(), [{String.t(), String.t()}], String.t() | nil) ::
          t()
  def from_response(status, body, headers \\ [], idempotency_key \\ nil) do
    body = normalise(body)
    request_id = find_header(headers, "cko-request-id")

    %__MODULE__{
      type: classify(status),
      status: status,
      request_id: request_id,
      idempotency_key: idempotency_key,
      error_type: body["error_type"],
      error_codes: Map.get(body, "error_codes", []),
      message: Map.get(body, "message", default_message(status)),
      raw: body
    }
  end

  @doc "Build a network-level `Error` (no HTTP response received)."
  @spec network_error(term()) :: t()
  def network_error(reason) do
    %__MODULE__{
      type: :network_error,
      status: nil,
      message: "Network error: #{inspect(reason)}",
      error_codes: [],
      raw: nil
    }
  end

  @doc "Build a generic `Error` from a type atom and message."
  @spec new(error_kind(), String.t()) :: t()
  def new(type, message) do
    %__MODULE__{type: type, message: message, error_codes: []}
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  defp classify(400), do: :validation_error
  defp classify(401), do: :auth_error
  defp classify(403), do: :auth_error
  defp classify(404), do: :not_found
  defp classify(409), do: :conflict
  defp classify(422), do: :validation_error
  defp classify(429), do: :rate_limited
  defp classify(s) when s >= 500, do: :server_error
  defp classify(_), do: :api_error

  defp default_message(400), do: "Bad request — check request parameters"
  defp default_message(401), do: "Unauthorized — invalid or expired credentials"
  defp default_message(403), do: "Forbidden — insufficient permissions"
  defp default_message(404), do: "Resource not found"
  defp default_message(409), do: "Conflict — possible idempotency key collision"
  defp default_message(422), do: "Unprocessable entity — validation failed"
  defp default_message(429), do: "Rate limited — back off and retry"
  defp default_message(500), do: "Internal server error at Checkout.com"
  defp default_message(502), do: "Bad gateway at Checkout.com"
  defp default_message(503), do: "Service unavailable at Checkout.com"
  defp default_message(504), do: "Gateway timeout at Checkout.com"
  defp default_message(s) when s >= 500, do: "Checkout.com server error (#{s})"
  defp default_message(s), do: "Unexpected API error (HTTP #{s})"

  defp normalise(body) when is_map(body), do: body

  defp normalise(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, map} when is_map(map) -> map
      _ -> %{"message" => body}
    end
  end

  defp normalise(_), do: %{}

  # headers_to_list/1 in Client always converts Req map headers to a list of
  # {name, value} pairs before calling from_response/4, so we only need the list path.
  defp find_header(headers, name) do
    Enum.find_value(headers, fn
      {^name, value} -> value
      _ -> nil
    end)
  end
end
