defmodule CheckoutClient.HTTP.Retry do
  @moduledoc """
  Retry strategy for Checkout.com API requests.

  Implements **full-jitter exponential backoff**:

      delay = :rand.uniform(min(base * 2^attempt, max_delay))

  This distributes retry load across the window rather than causing thundering-herd
  at a fixed interval, as recommended by AWS and aligned with Checkout.com guidance.

  ## Retry triggers

  - `429 Too Many Requests` — rate limited
  - `502`, `503`, `504`, and other `5xx` — transient server errors
  - TCP timeout or connection closed — network errors

  ## Not retried

  - `409 Conflict` — idempotency collision; must be handled by the caller
  - Any `4xx` other than `429` — client errors; retrying won't help
  """

  @doc "Returns `true` when the result should trigger a retry."
  @spec retryable?(term()) :: boolean()
  def retryable?({:ok, %{status: 429}}), do: true
  def retryable?({:ok, %{status: 502}}), do: true
  def retryable?({:ok, %{status: 503}}), do: true
  def retryable?({:ok, %{status: 504}}), do: true
  def retryable?({:ok, %{status: s}}) when s >= 500, do: true
  def retryable?({:error, %{reason: :timeout}}), do: true
  def retryable?({:error, %{reason: :closed}}), do: true
  def retryable?(_), do: false

  @doc """
  Computes the delay in milliseconds for `attempt` (0-indexed) using full-jitter
  exponential backoff.
  """
  @spec delay(non_neg_integer(), map()) :: non_neg_integer()
  def delay(attempt, %{retry_base_delay: base, retry_max_delay: max_delay}) do
    cap = min(trunc(base * :math.pow(2, attempt)), max_delay)
    # :rand.uniform(0) raises, so guard with max(cap, 1)
    :rand.uniform(max(cap, 1))
  end

  @doc "Returns the Req retry keyword options derived from the given config."
  @spec req_opts(map()) :: keyword()
  def req_opts(%{max_retries: 0}), do: [retry: false]

  def req_opts(config) do
    [
      retry: &retryable?/1,
      max_retries: config.max_retries,
      retry_delay: fn attempt -> delay(attempt, config) end,
      retry_log_level: :warning
    ]
  end
end
