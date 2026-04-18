defmodule CheckoutClient.Payments do
  @moduledoc """
  Checkout.com Payments API — the full payment lifecycle.

  Idempotency keys are automatically injected for `POST /payments` and all
  payment action endpoints per the Checkout.com idempotency spec.
  """

  alias CheckoutClient.Client

  @base "/payments"

  @doc """
  Request a payment or payout.

  Payout requests always return `202 Accepted`.
  """
  @spec request(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def request(body, opts \\ []), do: Client.post(@base, body, opts)

  @doc """
  List payments matching `reference`. Results are reverse-chronological.
  Only returns payments initiated from June 2022 onward.

  ## Options

    - `:limit` — number of results (default: 10)
    - `:skip` — offset (default: 0)
  """
  @spec list(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(reference, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)
    skip = Keyword.get(opts, :skip, 0)
    Client.get("#{@base}?reference=#{URI.encode(reference)}&limit=#{limit}&skip=#{skip}", opts)
  end

  @doc "Get full details of a payment by ID."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(payment_id, opts \\ []), do: Client.get("#{@base}/#{payment_id}", opts)

  @doc "Get all actions taken on a payment."
  @spec actions(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def actions(payment_id, opts \\ []),
    do: Client.get("#{@base}/#{payment_id}/actions", opts)

  @doc "Increment an existing authorization amount."
  @spec increment_auth(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def increment_auth(payment_id, body, opts \\ []),
    do: Client.post("#{@base}/#{payment_id}/authorizations", body, opts)

  @doc "Cancel a scheduled payment retry."
  @spec cancel_retry(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def cancel_retry(payment_id, body \\ %{}, opts \\ []),
    do: Client.post("#{@base}/#{payment_id}/cancellations", body, opts)

  @doc "Capture an authorized payment. Omit `amount` to capture in full."
  @spec capture(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def capture(payment_id, body \\ %{}, opts \\ []),
    do: Client.post("#{@base}/#{payment_id}/captures", body, opts)

  @doc "Refund a captured payment. Omit `amount` for a full refund."
  @spec refund(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def refund(payment_id, body \\ %{}, opts \\ []),
    do: Client.post("#{@base}/#{payment_id}/refunds", body, opts)

  @doc "Reverse a payment."
  @spec reverse(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def reverse(payment_id, body \\ %{}, opts \\ []),
    do: Client.post("#{@base}/#{payment_id}/reversals", body, opts)

  @doc "Void an uncaptured payment authorization."
  @spec void(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def void(payment_id, body \\ %{}, opts \\ []),
    do: Client.post("#{@base}/#{payment_id}/voids", body, opts)

  @doc "Search payments using structured filters."
  @spec search(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def search(query, opts \\ []), do: Client.post("#{@base}/search", query, opts)
end
