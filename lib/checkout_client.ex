defmodule CheckoutClient do
  @moduledoc """
  Production-grade Elixir client for the
  [Checkout.com API](https://www.checkout.com/docs/developer-resources/api).

  ## Quick start

      # config/runtime.exs
      config :checkout_client,
        prefix:            System.fetch_env!("CHECKOUT_PREFIX"),
        access_key_id:     System.get_env("CHECKOUT_ACCESS_KEY_ID"),
        access_key_secret: System.get_env("CHECKOUT_ACCESS_KEY_SECRET"),
        environment:       :production

      # Request a payment
      {:ok, payment} = CheckoutClient.Payments.request(%{
        amount:    10_000,
        currency:  "GBP",
        source:    %{type: "token", token: "tok_..."},
        reference: "ORD-001"
      })

      # Capture it
      {:ok, _} = CheckoutClient.Payments.capture(payment["id"])

  ## API modules

  | Module | Description |
  |---|---|
  | `CheckoutClient.Payments` | Full payment lifecycle |
  | `CheckoutClient.Payments.Flow` | Hosted payment sessions |
  | `CheckoutClient.Payments.Links` | Shareable payment links |
  | `CheckoutClient.Payments.HostedPage` | Hosted payments page |
  | `CheckoutClient.Payments.Contexts` | Payment contexts |
  | `CheckoutClient.Payments.Setups` | Payment setups |
  | `CheckoutClient.Payments.Methods` | Available payment methods |
  | `CheckoutClient.Tokens` | Card tokenization |
  | `CheckoutClient.Instruments` | Vaulted payment instruments |
  | `CheckoutClient.Customers` | Customer profiles |
  | `CheckoutClient.Forward` | Forward API + vault secrets |
  | `CheckoutClient.Disputes` | Dispute lifecycle management |
  | `CheckoutClient.Workflows` | Event-driven notifications |
  | `CheckoutClient.Transfers` | Fund transfers |
  | `CheckoutClient.Balances` | Entity balances |
  | `CheckoutClient.Forex` | Indicative FX rates |
  | `CheckoutClient.Sessions` | Standalone 3DS sessions |
  | `CheckoutClient.ApplePay` | Apple Pay setup |
  | `CheckoutClient.GooglePay` | Google Pay setup |
  | `CheckoutClient.Issuing.Cardholders` | Cardholder management |
  | `CheckoutClient.Issuing.Cards` | Card lifecycle |
  | `CheckoutClient.Issuing.Controls` | Spending controls |
  | `CheckoutClient.Issuing.ControlProfiles` | Control profiles |
  | `CheckoutClient.Issuing.ControlGroups` | Control groups |
  | `CheckoutClient.Issuing.CardholderAccessTokens` | Secure cardholder tokens |
  | `CheckoutClient.Issuing.Transactions` | Issuing transactions |
  | `CheckoutClient.Issuing.Disputes` | Issuing disputes |
  | `CheckoutClient.Issuing.Sandbox` | Sandbox simulation |
  | `CheckoutClient.Platforms.Entities` | Sub-entity onboarding |
  | `CheckoutClient.Platforms.PaymentInstruments` | Platform payment instruments |
  | `CheckoutClient.Platforms.PayoutSchedules` | Payout schedules |
  | `CheckoutClient.Platforms.ReserveRules` | Reserve rules |
  | `CheckoutClient.Reports` | Financial reports |
  | `CheckoutClient.FinancialActions` | Financial actions |
  | `CheckoutClient.Identity.Applicants` | Identity applicants |
  | `CheckoutClient.Identity.Verification` | Identity verification |
  | `CheckoutClient.Identity.AML` | AML screening |
  | `CheckoutClient.Identity.FaceAuth` | Face authentication |
  | `CheckoutClient.Identity.Documents` | ID document verification |
  | `CheckoutClient.NetworkTokens` | Network tokens + cryptograms |
  | `CheckoutClient.CardMetadata` | BIN-level card metadata |
  | `CheckoutClient.AccountUpdater` | Real-time account updater |
  | `CheckoutClient.Compliance` | Compliance request responses |
  | `CheckoutClient.AgenticCommerce` | AI agent delegated payment tokens |

  ## Error handling

  All functions return `{:ok, map()}` or `{:error, %CheckoutClient.Error{}}`.

      case CheckoutClient.Payments.capture(id) do
        {:ok, result} -> handle(result)
        {:error, %CheckoutClient.Error{type: :not_found}} -> handle_missing()
        {:error, %CheckoutClient.Error{type: :rate_limited}} -> schedule_retry()
        {:error, %CheckoutClient.Error{} = err} -> Logger.error(Exception.message(err))
      end

  ## Multi-tenant

      client = CheckoutClient.client(prefix: "abcd1234", secret_key: "sk_...")
      CheckoutClient.Payments.request(body, client: client)
  """

  alias CheckoutClient.Config

  @doc """
  Returns the resolved configuration map, optionally merged with `overrides`.
  """
  @spec config(keyword()) :: Config.t()
  def config(overrides \\ []), do: Config.resolve(overrides)

  @doc """
  Builds a client map for multi-tenant usage. Pass it as `client: client`
  to any resource function to override the global config for that request.

  ## Example

      client = CheckoutClient.client(
        prefix:     merchant.cko_prefix,
        secret_key: merchant.cko_secret_key
      )
      CheckoutClient.Payments.request(body, client: client)
  """
  @spec client(keyword()) :: %{config: Config.t()}
  def client(opts \\ []), do: %{config: Config.resolve(opts)}
end
