defmodule CheckoutClient.HTTP.Idempotency do
  @moduledoc """
  Idempotency key management per the
  [Checkout.com idempotency docs](https://www.checkout.com/docs/developer-resources/api/idempotency).

  The following `POST` endpoints support `Cko-Idempotency-Key`:

  - `/payment-contexts`
  - `/payments`
  - `/payments/{id}/authorizations`
  - `/payments/{id}/cancellations`
  - `/payments/{id}/captures`
  - `/payments/{id}/refunds`
  - `/payments/{id}/voids`
  - `/transfers`

  Keys are V4 UUIDs, cached for 24 hours. Concurrent requests with the same
  key return `409 Conflict`.
  """

  @idempotent_prefixes [
    "/payment-contexts",
    "/payments",
    "/transfers"
  ]

  @doc "Returns `true` when the method+path combination requires an idempotency key."
  @spec required?(atom(), String.t()) :: boolean()
  def required?(:post, path),
    do: Enum.any?(@idempotent_prefixes, &String.starts_with?(path, &1))

  def required?(_, _), do: false

  @doc """
  Generates a V4 UUID, optionally prefixed.

      iex> key = CheckoutClient.HTTP.Idempotency.generate(nil)
      iex> String.match?(key, ~r/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/)
      true
  """
  @spec generate(String.t() | nil) :: String.t()
  def generate(prefix) do
    uuid = uuid4()
    if prefix, do: "#{prefix}-#{uuid}", else: uuid
  end

  @doc """
  Resolves the idempotency key to use for a request:

  1. Uses `opts[:idempotency_key]` if explicitly provided.
  2. Auto-generates a key if the endpoint requires one.
  3. Returns `nil` for non-idempotent endpoints.
  """
  @spec resolve(atom(), String.t(), keyword()) :: String.t() | nil
  def resolve(method, path, opts) do
    explicit = Keyword.get(opts, :idempotency_key)
    config_prefix = get_in(opts, [:_config, :idempotency_key_prefix])

    cond do
      explicit -> explicit
      required?(method, path) -> generate(config_prefix)
      true -> nil
    end
  end

  # ---------------------------------------------------------------------------
  # Private — RFC 4122 V4 UUID
  # ---------------------------------------------------------------------------

  @spec uuid4() :: String.t()
  defp uuid4 do
    <<a1, a2, a3, a4, b1, b2, c1, c2, d1, d2, e1, e2, e3, e4, e5, e6>> =
      :crypto.strong_rand_bytes(16)

    # Set version bits (4) and variant bits (10xx)
    c1 = Bitwise.bor(Bitwise.band(c1, 0x0F), 0x40)
    d1 = Bitwise.bor(Bitwise.band(d1, 0x3F), 0x80)

    :io_lib.format(
      "~2.16.0b~2.16.0b~2.16.0b~2.16.0b-~2.16.0b~2.16.0b-~2.16.0b~2.16.0b" <>
        "-~2.16.0b~2.16.0b-~2.16.0b~2.16.0b~2.16.0b~2.16.0b~2.16.0b~2.16.0b",
      [a1, a2, a3, a4, b1, b2, c1, c2, d1, d2, e1, e2, e3, e4, e5, e6]
    )
    |> IO.iodata_to_binary()
  end
end
