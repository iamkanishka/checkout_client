defmodule CheckoutClient.Behaviours.HTTP do
  @moduledoc """
  HTTP behaviour for `CheckoutClient.Client`. Implement to swap the real Req-based
  client with a `Mox` mock in tests, or to add a circuit-breaker wrapper.

  ## Test usage

      # In test/support/mocks.ex
      Mox.defmock(CheckoutClient.MockHTTP, for: CheckoutClient.Behaviours.HTTP)

      # In a test
      expect(CheckoutClient.MockHTTP, :request, fn :post, "/payments", _body, _opts ->
        {:ok, %{status: 201, body: %{"id" => "pay_test"}, headers: []}}
      end)
  """

  @type method :: :get | :post | :put | :patch | :delete
  @type path :: String.t()
  @type body :: map() | nil
  @type opts :: keyword()
  @type raw_response :: %{
          status: non_neg_integer(),
          body: term(),
          headers: list({String.t(), String.t()})
        }

  @callback request(method(), path(), body(), opts()) ::
              {:ok, raw_response()} | {:error, term()}
end

defmodule CheckoutClient.Behaviours.Auth do
  @moduledoc """
  Auth behaviour for `CheckoutClient.Auth`. Implement to mock token fetching
  in tests or to source tokens from external credential stores.

  ## Test usage

      Mox.defmock(CheckoutClient.MockAuth, for: CheckoutClient.Behaviours.Auth)

      expect(CheckoutClient.MockAuth, :get_token, fn _config ->
        {:ok, "test-bearer-token"}
      end)
  """

  @callback get_token(map()) :: {:ok, String.t()} | {:error, term()}
  @callback invalidate(map()) :: :ok
end
