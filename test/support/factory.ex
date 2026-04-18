defmodule CheckoutClient.Factory do
  @moduledoc "Test data factory for CheckoutClient tests."

  @doc "Build a payment response map."
  @spec payment(map()) :: map()
  def payment(overrides \\ %{}) do
    Map.merge(
      %{
        "id" => "pay_" <> random_id(),
        "status" => "Authorized",
        "amount" => 10_000,
        "currency" => "GBP",
        "reference" => "ORD-#{:rand.uniform(9999)}",
        "approved" => true,
        "response_code" => "10000",
        "response_summary" => "Approved"
      },
      overrides
    )
  end

  @doc "Build a Checkout.com error response body."
  @spec error_body(String.t(), [String.t()]) :: map()
  def error_body(error_type \\ "request_invalid", codes \\ ["amount_invalid"]) do
    %{
      "error_type" => error_type,
      "error_codes" => codes,
      "message" => "One or more fields failed validation"
    }
  end

  @doc "Build a token response map."
  @spec token(map()) :: map()
  def token(overrides \\ %{}) do
    Map.merge(
      %{
        "type" => "card",
        "token" => "tok_" <> random_id(),
        "scheme" => "Visa",
        "last4" => "4242",
        "bin" => "424242"
      },
      overrides
    )
  end

  @spec random_id() :: String.t()
  defp random_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end
end
