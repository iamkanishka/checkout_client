defmodule CheckoutClient.Auth do
  @moduledoc """
  Selects and resolves the correct authentication credential for each request.

  Priority order (highest first):

  1. **OAuth 2.0** — if `access_key_id` + `access_key_secret` are both set
  2. **Secret key** — if `secret_key` is set
  3. **Public key** — if `public_key` is set (client-side only)
  """

  alias CheckoutClient.{Auth.TokenStore, Config}

  @doc """
  Resolves a `Bearer <token>` string for the given config.

  Uses `TokenStore` for OAuth to get a cached or freshly-fetched JWT.
  Returns `{:ok, header_value}` or `{:error, reason}`.
  """
  @spec resolve(Config.t()) :: {:ok, String.t()} | {:error, term()}
  def resolve(config) do
    cond do
      Config.oauth_configured?(config) ->
        case TokenStore.get_token(config) do
          {:ok, token} -> {:ok, "Bearer #{token}"}
          {:error, _} = err -> err
        end

      Config.secret_key_configured?(config) ->
        {:ok, "Bearer #{config.secret_key}"}

      is_binary(config[:public_key]) ->
        {:ok, "Bearer #{config.public_key}"}

      true ->
        {:error, :no_auth_credentials}
    end
  end

  @doc "Invalidates the OAuth token cache entry for this config (called on 401)."
  @spec invalidate(Config.t()) :: :ok
  def invalidate(config), do: TokenStore.invalidate(config)
end
