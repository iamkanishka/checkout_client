defmodule CheckoutClient.Payments.Flow do
  @moduledoc "Flow API — Checkout.com-hosted payment UI sessions."

  alias CheckoutClient.Client

  @doc "Create a Flow payment session."
  @spec create_session(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create_session(body, opts \\ []), do: Client.post("/payment-sessions", body, opts)

  @doc "Submit an existing Flow payment session."
  @spec submit_session(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def submit_session(session_id, body, opts \\ []),
    do: Client.post("/payment-sessions/#{session_id}/submit", body, opts)

  @doc "Create and immediately submit a Flow session in a single call."
  @spec create_and_submit(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create_and_submit(body, opts \\ []),
    do: Client.post("/payment-sessions/collect", body, opts)
end

defmodule CheckoutClient.Payments.Links do
  @moduledoc "Payment Links API — generate shareable links for checkout."

  alias CheckoutClient.Client

  @doc "Create a payment link."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/payment-links", body, opts)

  @doc "Get details of a payment link."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(link_id, opts \\ []), do: Client.get("/payment-links/#{link_id}", opts)
end

defmodule CheckoutClient.Payments.HostedPage do
  @moduledoc "Hosted Payments Page (HPP) API."

  alias CheckoutClient.Client

  @doc "Create a Hosted Payments Page session."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/hosted-payments", body, opts)

  @doc "Get details of a Hosted Payments Page session."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(page_id, opts \\ []), do: Client.get("/hosted-payments/#{page_id}", opts)
end

defmodule CheckoutClient.Payments.Contexts do
  @moduledoc """
  Payment Contexts API — pre-authorise context ahead of payment.
  Idempotency key auto-injected.
  """

  alias CheckoutClient.Client

  @doc "Request a payment context."
  @spec request(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def request(body, opts \\ []), do: Client.post("/payment-contexts", body, opts)

  @doc "Get details of a payment context."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(context_id, opts \\ []), do: Client.get("/payment-contexts/#{context_id}", opts)
end

defmodule CheckoutClient.Payments.Setups do
  @moduledoc "Payment Setups API — multi-step payment flows."

  alias CheckoutClient.Client

  @doc "Create a payment setup."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/payment-setups", body, opts)

  @doc "Update a payment setup."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(setup_id, body, opts \\ []),
    do: Client.put("/payment-setups/#{setup_id}", body, opts)

  @doc "Get a payment setup."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(setup_id, opts \\ []), do: Client.get("/payment-setups/#{setup_id}", opts)

  @doc "Confirm a payment setup."
  @spec confirm(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def confirm(setup_id, body \\ %{}, opts \\ []),
    do: Client.post("/payment-setups/#{setup_id}/confirm", body, opts)
end

defmodule CheckoutClient.Payments.Methods do
  @moduledoc "Payment Methods API — query available payment methods."

  alias CheckoutClient.Client

  @doc "Get available payment methods."
  @spec list(keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(opts \\ []), do: Client.get("/payment-methods", opts)
end

defmodule CheckoutClient.Forex do
  @moduledoc """
  FX Rates API — indicative foreign exchange rates for Card Payouts and
  daily acquiring. Rates include your FX markup and are updated daily by
  Visa (excluding weekends/holidays) and Mastercard.
  """

  alias CheckoutClient.Client

  @doc """
  Get indicative FX rates.

  ## Query parameters

    - `:product` — `"card_payouts"` or `"daily_acquiring"` (required)
    - `:source` — `"visa"` or `"mastercard"` (required)
    - `:currency_pairs` — comma-separated pairs, e.g. `"GBPUSD,EURUSD"`
    - `:processing_channel_id` — processing channel ID
  """
  @spec get_rates(keyword(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_rates(params \\ [], opts \\ []) do
    qs = params |> Keyword.drop([:client]) |> URI.encode_query()
    path = if qs == "", do: "/forex/rates", else: "/forex/rates?#{qs}"
    Client.get(path, opts)
  end
end

defmodule CheckoutClient.Tokens do
  @moduledoc """
  Tokens API — tokenize card data client-side. Use your **public key** for
  this call. Tokens are single-use and expire after 15 minutes.
  """

  alias CheckoutClient.Client

  @doc "Request a token for card or wallet data."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/tokens", body, opts)
end

defmodule CheckoutClient.Instruments do
  @moduledoc "Instruments API — store and manage vaulted payment credentials."

  alias CheckoutClient.Client

  @doc "Create (vault) a new instrument."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/instruments", body, opts)

  @doc "Get instrument details."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(instrument_id, opts \\ []),
    do: Client.get("/instruments/#{instrument_id}", opts)

  @doc "Update an instrument (e.g., update card expiry)."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(instrument_id, body, opts \\ []),
    do: Client.patch("/instruments/#{instrument_id}", body, opts)

  @doc "Delete an instrument from the vault."
  @spec delete(String.t(), keyword()) :: {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def delete(instrument_id, opts \\ []),
    do: Client.delete("/instruments/#{instrument_id}", opts)

  @doc "Get bank account field formatting requirements for a country/currency."
  @spec bank_account_field_formatting(keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def bank_account_field_formatting(opts \\ []),
    do: Client.get("/validation/bank-accounts", opts)
end

defmodule CheckoutClient.Customers do
  @moduledoc "Customers API — create and manage customer profiles."

  alias CheckoutClient.Client

  @doc "Create a customer."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/customers", body, opts)

  @doc "Get a customer by ID or email."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(customer_id, opts \\ []), do: Client.get("/customers/#{customer_id}", opts)

  @doc "Update customer details."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(customer_id, body, opts \\ []),
    do: Client.patch("/customers/#{customer_id}", body, opts)

  @doc "Delete a customer."
  @spec delete(String.t(), keyword()) :: {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def delete(customer_id, opts \\ []),
    do: Client.delete("/customers/#{customer_id}", opts)
end

defmodule CheckoutClient.Sessions do
  @moduledoc "Standalone 3DS Sessions API — decouple 3DS auth from payment."

  alias CheckoutClient.Client

  @doc "Request a new 3DS session."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/sessions", body, opts)

  @doc "Get session details."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(session_id, opts \\ []), do: Client.get("/sessions/#{session_id}", opts)

  @doc "Update a session."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(session_id, body, opts \\ []),
    do: Client.put("/sessions/#{session_id}", body, opts)

  @doc "Complete a session."
  @spec complete(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def complete(session_id, body \\ %{}, opts \\ []),
    do: Client.post("/sessions/#{session_id}/complete", body, opts)

  @doc "Update the 3DS Method completion indicator."
  @spec update_3ds_method(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update_3ds_method(session_id, body, opts \\ []),
    do: Client.put("/sessions/#{session_id}/3ds-method-completion", body, opts)
end

defmodule CheckoutClient.Transfers do
  @moduledoc "Transfers API — move funds between entities. Idempotency key auto-injected."

  alias CheckoutClient.Client

  @doc "Initiate a fund transfer."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/transfers", body, opts)

  @doc "Retrieve a transfer by ID."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(transfer_id, opts \\ []), do: Client.get("/transfers/#{transfer_id}", opts)
end

defmodule CheckoutClient.Balances do
  @moduledoc "Balances API — retrieve entity balances."

  alias CheckoutClient.Client

  @doc "Get balances for an entity."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(entity_id, opts \\ []), do: Client.get("/balances/#{entity_id}", opts)
end

defmodule CheckoutClient.CardMetadata do
  @moduledoc "Card Metadata API — BIN-level card metadata."

  alias CheckoutClient.Client

  @doc "Get card metadata for a BIN or full card number."
  @spec get(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(body, opts \\ []), do: Client.post("/metadata/card", body, opts)
end

defmodule CheckoutClient.AccountUpdater do
  @moduledoc "Standalone Account Updater API — retrieve updated card credentials."

  alias CheckoutClient.Client

  @doc "Get updated card credentials for a stored instrument."
  @spec get_updated_credentials(map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_updated_credentials(body, opts \\ []),
    do: Client.post("/account-updater/card-credentials", body, opts)
end

defmodule CheckoutClient.ApplePay do
  @moduledoc """
  Apple Pay API — manage Apple Pay merchant certificates and domain enrollment.

  Setup flow:
  1. `generate_csr/2` — generate a Certificate Signing Request
  2. Submit CSR to Apple Developer Portal to obtain a `.cer` certificate
  3. `upload_certificate/2` — upload the certificate to Checkout.com
  4. `enroll_domain/2` — enroll your merchant domain
  """

  alias CheckoutClient.Client

  @doc "Generate a Certificate Signing Request (CSR) for Apple Pay."
  @spec generate_csr(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def generate_csr(body \\ %{}, opts \\ []),
    do: Client.post("/applepay/certificates/signingrequests", body, opts)

  @doc "Upload an Apple Pay payment processing certificate."
  @spec upload_certificate(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def upload_certificate(body, opts \\ []),
    do: Client.post("/applepay/certificates", body, opts)

  @doc "Enroll a merchant domain with the Apple Pay service."
  @spec enroll_domain(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def enroll_domain(body, opts \\ []), do: Client.post("/applepay/domains", body, opts)
end

defmodule CheckoutClient.GooglePay do
  @moduledoc """
  Google Pay API — manage Google Pay merchant enrollment and domain registration.

  Setup flow:
  1. `enroll_entity/2` — enroll your entity with Google Pay
  2. `register_domain/3` — register your web domain(s)
  """

  alias CheckoutClient.Client

  @doc "Enroll an entity with the Google Pay service."
  @spec enroll_entity(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def enroll_entity(body, opts \\ []),
    do: Client.post("/google-pay/merchants", body, opts)

  @doc "Register a web domain for an enrolled Google Pay entity."
  @spec register_domain(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def register_domain(entity_id, body, opts \\ []),
    do: Client.post("/google-pay/merchants/#{entity_id}/domains", body, opts)

  @doc "Get all registered domains for an enrolled entity."
  @spec get_registered_domains(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_registered_domains(entity_id, opts \\ []),
    do: Client.get("/google-pay/merchants/#{entity_id}/domains", opts)

  @doc "Get the Google Pay enrollment state for an entity."
  @spec get_enrollment_state(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_enrollment_state(entity_id, opts \\ []),
    do: Client.get("/google-pay/merchants/#{entity_id}", opts)
end

defmodule CheckoutClient.NetworkTokens do
  @moduledoc "Network Tokens API — provision and manage network tokens and cryptograms."

  alias CheckoutClient.Client

  @doc "Provision a network token."
  @spec provision(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def provision(body, opts \\ []), do: Client.post("/network-tokens", body, opts)

  @doc "Get a network token."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(token_id, opts \\ []), do: Client.get("/network-tokens/#{token_id}", opts)

  @doc "Request a cryptogram (TAVV) for a network token."
  @spec request_cryptogram(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def request_cryptogram(token_id, body \\ %{}, opts \\ []),
    do: Client.post("/network-tokens/#{token_id}/cryptogram", body, opts)

  @doc "Permanently delete a network token."
  @spec delete(String.t(), keyword()) :: {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def delete(token_id, opts \\ []),
    do: Client.delete("/network-tokens/#{token_id}", opts)
end

defmodule CheckoutClient.Forward do
  @moduledoc """
  Forward API — forward requests to third-party services using vaulted secrets.

  Secrets stored in the vault are injected at request time as `{{secret-name}}`
  placeholders, so they are never exposed in your application code.
  """

  alias CheckoutClient.Client

  @doc "Forward an API request to a third-party URL."
  @spec forward_request(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def forward_request(body, opts \\ []), do: Client.post("/forward", body, opts)

  @doc "Retrieve details of a past forward request."
  @spec get_forward_request(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_forward_request(forward_id, opts \\ []),
    do: Client.get("/forward/#{forward_id}", opts)

  @doc "Store a new named secret in the vault."
  @spec create_secret(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create_secret(body, opts \\ []), do: Client.post("/forward/secrets", body, opts)

  @doc "List all secrets (metadata only — values are never returned)."
  @spec list_secrets(keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list_secrets(opts \\ []), do: Client.get("/forward/secrets", opts)

  @doc "Update a secret's value."
  @spec update_secret(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update_secret(secret_id, body, opts \\ []),
    do: Client.patch("/forward/secrets/#{secret_id}", body, opts)

  @doc "Permanently delete a secret. This action is irreversible."
  @spec delete_secret(String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def delete_secret(secret_id, opts \\ []),
    do: Client.delete("/forward/secrets/#{secret_id}", opts)
end

defmodule CheckoutClient.Compliance do
  @moduledoc """
  Compliance Requests API — retrieve and respond to compliance requests.

  Checkout.com issues compliance requests when additional documentation is
  required (KYC/AML, sanctions screening, PCI evidence). Respond promptly
  to avoid account restrictions.
  """

  alias CheckoutClient.Client

  @doc "Get a compliance request by ID."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(request_id, opts \\ []),
    do: Client.get("/compliance/requests/#{request_id}", opts)

  @doc "Submit a response to a compliance request."
  @spec respond(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def respond(request_id, body, opts \\ []),
    do: Client.post("/compliance/requests/#{request_id}/responses", body, opts)
end

defmodule CheckoutClient.AgenticCommerce do
  @moduledoc """
  Agentic Commerce Protocol — delegated payment tokens for AI agents.

  Issue spending-constrained tokens to AI agents so they can initiate
  payments on a user's behalf without holding full payment credentials.
  Checkout.com enforces the constraints server-side.
  """

  alias CheckoutClient.Client

  @doc """
  Create a delegated payment token for an AI agent.

  ## Example

      {:ok, %{"token" => token}} =
        CheckoutClient.AgenticCommerce.create_delegated_token(%{
          principal:   %{type: "customer", customer_id: "cus_abc"},
          agent:       %{name: "shopping-assistant-v1", type: "llm_agent"},
          constraints: %{max_amount: 5_000, currency: "GBP", expires_on: "2025-12-31T23:59:59Z"}
        })
  """
  @spec create_delegated_token(map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create_delegated_token(body, opts \\ []),
    do: Client.post("/agentic-commerce/delegated-payment-tokens", body, opts)
end
