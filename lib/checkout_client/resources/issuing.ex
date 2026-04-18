defmodule CheckoutClient.Issuing.Cardholders do
  @moduledoc "Card Issuing — Cardholders API."

  alias CheckoutClient.Client

  @doc "Create a cardholder."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/issuing/cardholders", body, opts)

  @doc "Get cardholder details."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(cardholder_id, opts \\ []),
    do: Client.get("/issuing/cardholders/#{cardholder_id}", opts)

  @doc "Update cardholder details."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(cardholder_id, body, opts \\ []),
    do: Client.patch("/issuing/cardholders/#{cardholder_id}", body, opts)

  @doc "List all cards issued to a cardholder."
  @spec list_cards(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list_cards(cardholder_id, opts \\ []),
    do: Client.get("/issuing/cardholders/#{cardholder_id}/cards", opts)
end

defmodule CheckoutClient.Issuing.CardholderAccessTokens do
  @moduledoc """
  Card Issuing — Cardholder Access Tokens API.

  Short-lived tokens scoped to a cardholder, used to authenticate
  sensitive operations (e.g., displaying the full PAN and CVV) in a
  secure client-side widget.
  """

  alias CheckoutClient.Client

  @doc "Request a cardholder access token."
  @spec request(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def request(cardholder_id, body \\ %{}, opts \\ []),
    do: Client.post("/issuing/cardholders/#{cardholder_id}/access-tokens", body, opts)
end

defmodule CheckoutClient.Issuing.Cards do
  @moduledoc "Card Issuing — Cards API. Full card lifecycle."

  alias CheckoutClient.Client

  @doc "Create a card."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/issuing/cards", body, opts)

  @doc "Get card details."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(card_id, opts \\ []), do: Client.get("/issuing/cards/#{card_id}", opts)

  @doc "Update card details."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(card_id, body, opts \\ []),
    do: Client.patch("/issuing/cards/#{card_id}", body, opts)

  @doc "Get card credentials (PAN, CVV). Requires a cardholder access token."
  @spec get_credentials(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_credentials(card_id, opts \\ []),
    do: Client.get("/issuing/cards/#{card_id}/credentials", opts)

  @doc "Activate a card."
  @spec activate(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def activate(card_id, opts \\ []),
    do: Client.post("/issuing/cards/#{card_id}/activate", %{}, opts)

  @doc "Suspend a card (temporarily block transactions)."
  @spec suspend(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def suspend(card_id, body \\ %{}, opts \\ []),
    do: Client.post("/issuing/cards/#{card_id}/suspend", body, opts)

  @doc "Revoke a card (permanently cancel)."
  @spec revoke(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def revoke(card_id, body \\ %{}, opts \\ []),
    do: Client.post("/issuing/cards/#{card_id}/revoke", body, opts)

  @doc "Renew a card (re-issue with new expiry/CVV)."
  @spec renew(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def renew(card_id, body \\ %{}, opts \\ []),
    do: Client.post("/issuing/cards/#{card_id}/renew", body, opts)

  @doc "Schedule a future revocation date."
  @spec schedule_revocation(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def schedule_revocation(card_id, body, opts \\ []),
    do: Client.post("/issuing/cards/#{card_id}/revoke/schedule", body, opts)

  @doc "Delete a scheduled revocation."
  @spec delete_scheduled_revocation(String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def delete_scheduled_revocation(card_id, opts \\ []),
    do: Client.delete("/issuing/cards/#{card_id}/revoke/schedule", opts)

  @doc "Enrol a card in 3DS."
  @spec enrol_3ds(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def enrol_3ds(card_id, body, opts \\ []),
    do: Client.post("/issuing/cards/#{card_id}/3ds-enrollment", body, opts)

  @doc "Get a card's 3DS enrollment details."
  @spec get_3ds_enrollment(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_3ds_enrollment(card_id, opts \\ []),
    do: Client.get("/issuing/cards/#{card_id}/3ds-enrollment", opts)

  @doc "Update a card's 3DS enrollment details."
  @spec update_3ds_enrollment(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update_3ds_enrollment(card_id, body, opts \\ []),
    do: Client.patch("/issuing/cards/#{card_id}/3ds-enrollment", body, opts)
end

defmodule CheckoutClient.Issuing.Controls do
  @moduledoc "Card Issuing — Controls API. Spending controls per card or cardholder."

  alias CheckoutClient.Client

  @doc "Create a spending control."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/issuing/controls", body, opts)

  @doc "List controls for a target (card or cardholder ID)."
  @spec list_by_target(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list_by_target(target_id, opts \\ []),
    do: Client.get("/issuing/controls?target_id=#{target_id}", opts)

  @doc "Get a control by ID."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(control_id, opts \\ []), do: Client.get("/issuing/controls/#{control_id}", opts)

  @doc "Update a control."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(control_id, body, opts \\ []),
    do: Client.put("/issuing/controls/#{control_id}", body, opts)

  @doc "Remove a control."
  @spec delete(String.t(), keyword()) :: {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def delete(control_id, opts \\ []),
    do: Client.delete("/issuing/controls/#{control_id}", opts)
end

defmodule CheckoutClient.Issuing.ControlProfiles do
  @moduledoc "Card Issuing — Control Profiles API. Reusable groups of controls."

  alias CheckoutClient.Client

  @doc "Create a control profile."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/issuing/control-profiles", body, opts)

  @doc "List all control profiles."
  @spec list(keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(opts \\ []), do: Client.get("/issuing/control-profiles", opts)

  @doc "Get a control profile."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(profile_id, opts \\ []),
    do: Client.get("/issuing/control-profiles/#{profile_id}", opts)

  @doc "Update a control profile."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(profile_id, body, opts \\ []),
    do: Client.patch("/issuing/control-profiles/#{profile_id}", body, opts)

  @doc "Delete a control profile."
  @spec delete(String.t(), keyword()) :: {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def delete(profile_id, opts \\ []),
    do: Client.delete("/issuing/control-profiles/#{profile_id}", opts)

  @doc "Add a target to a control profile."
  @spec add_target(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def add_target(profile_id, body, opts \\ []),
    do: Client.post("/issuing/control-profiles/#{profile_id}/targets", body, opts)

  @doc "Remove a target from a control profile."
  @spec remove_target(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def remove_target(profile_id, body, opts \\ []),
    do: Client.post("/issuing/control-profiles/#{profile_id}/targets/remove", body, opts)
end

defmodule CheckoutClient.Issuing.ControlGroups do
  @moduledoc "Card Issuing — Control Groups API."

  alias CheckoutClient.Client

  @doc "Create a control group."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/issuing/control-groups", body, opts)

  @doc "List control groups for a target."
  @spec list_by_target(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list_by_target(target_id, opts \\ []),
    do: Client.get("/issuing/control-groups?target_id=#{target_id}", opts)

  @doc "Get a control group by ID."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(group_id, opts \\ []), do: Client.get("/issuing/control-groups/#{group_id}", opts)

  @doc "Delete a control group."
  @spec delete(String.t(), keyword()) :: {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def delete(group_id, opts \\ []),
    do: Client.delete("/issuing/control-groups/#{group_id}", opts)
end

defmodule CheckoutClient.Issuing.Transactions do
  @moduledoc "Card Issuing — Transactions API."

  alias CheckoutClient.Client

  @doc "List issuing transactions."
  @spec list(keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(opts \\ []), do: Client.get("/issuing/transactions", opts)

  @doc "Get a single issuing transaction."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(transaction_id, opts \\ []),
    do: Client.get("/issuing/transactions/#{transaction_id}", opts)
end

defmodule CheckoutClient.Issuing.Disputes do
  @moduledoc "Card Issuing — Issuing Disputes API."

  alias CheckoutClient.Client

  @doc "Create an issuing dispute."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/issuing/disputes", body, opts)

  @doc "Get an issuing dispute."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(dispute_id, opts \\ []), do: Client.get("/issuing/disputes/#{dispute_id}", opts)

  @doc "Cancel an issuing dispute."
  @spec cancel(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def cancel(dispute_id, opts \\ []),
    do: Client.post("/issuing/disputes/#{dispute_id}/cancel", %{}, opts)

  @doc "Escalate an issuing dispute."
  @spec escalate(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def escalate(dispute_id, opts \\ []),
    do: Client.post("/issuing/disputes/#{dispute_id}/escalate", %{}, opts)

  @doc "Submit an issuing dispute for review."
  @spec submit(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def submit(dispute_id, body \\ %{}, opts \\ []),
    do: Client.post("/issuing/disputes/#{dispute_id}/submit", body, opts)

  @doc "Accept an issuing dispute."
  @spec accept(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def accept(dispute_id, opts \\ []),
    do: Client.post("/issuing/disputes/#{dispute_id}/accept", %{}, opts)
end

defmodule CheckoutClient.Issuing.Sandbox do
  @moduledoc "Card Issuing — Sandbox simulation endpoints (sandbox only)."

  alias CheckoutClient.Client

  @doc "Simulate an authorization."
  @spec simulate_auth(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def simulate_auth(body, opts \\ []),
    do: Client.post("/issuing/simulate/authorizations", body, opts)

  @doc "Simulate an incremental authorization."
  @spec simulate_incremental_auth(map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def simulate_incremental_auth(body, opts \\ []),
    do: Client.post("/issuing/simulate/authorizations/increment", body, opts)

  @doc "Simulate a clearing (presentment)."
  @spec simulate_clearing(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def simulate_clearing(body, opts \\ []),
    do: Client.post("/issuing/simulate/clearing", body, opts)

  @doc "Simulate a refund."
  @spec simulate_refund(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def simulate_refund(body, opts \\ []),
    do: Client.post("/issuing/simulate/refunds", body, opts)

  @doc "Simulate a reversal."
  @spec simulate_reversal(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def simulate_reversal(body, opts \\ []),
    do: Client.post("/issuing/simulate/reversals", body, opts)
end
