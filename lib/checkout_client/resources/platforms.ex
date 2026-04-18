defmodule CheckoutClient.Platforms.Entities do
  @moduledoc "Platforms — Entities API. Onboard and manage sub-entities."

  alias CheckoutClient.Client

  @doc "Onboard a new sub-entity."
  @spec onboard(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def onboard(body, opts \\ []), do: Client.post("/accounts/entities", body, opts)

  @doc "Get entity details."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(entity_id, opts \\ []),
    do: Client.get("/accounts/entities/#{entity_id}", opts)

  @doc "Update entity details."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(entity_id, body, opts \\ []),
    do: Client.put("/accounts/entities/#{entity_id}", body, opts)

  @doc "Upload a KYB/KYC document file."
  @spec upload_file(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def upload_file(body, opts \\ []), do: Client.post("/accounts/files", body, opts)

  @doc "Retrieve a previously uploaded file."
  @spec get_file(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_file(file_id, opts \\ []), do: Client.get("/accounts/files/#{file_id}", opts)

  @doc "List sub-entity team members."
  @spec list_members(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list_members(entity_id, opts \\ []),
    do: Client.get("/accounts/entities/#{entity_id}/members", opts)

  @doc "Reinvite a sub-entity member."
  @spec reinvite_member(String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def reinvite_member(entity_id, member_id, opts \\ []),
    do:
      Client.put(
        "/accounts/entities/#{entity_id}/members/#{member_id}/reinvite",
        %{},
        opts
      )
end

defmodule CheckoutClient.Platforms.PaymentInstruments do
  @moduledoc "Platforms — Payment Instruments API."

  alias CheckoutClient.Client

  @doc "Add a payment instrument to a sub-entity."
  @spec add(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def add(entity_id, body, opts \\ []),
    do: Client.post("/accounts/entities/#{entity_id}/payment-instruments", body, opts)

  @doc "Get a payment instrument."
  @spec get(String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(entity_id, instrument_id, opts \\ []),
    do:
      Client.get(
        "/accounts/entities/#{entity_id}/payment-instruments/#{instrument_id}",
        opts
      )

  @doc "Update a payment instrument."
  @spec update(String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(entity_id, instrument_id, body, opts \\ []),
    do:
      Client.patch(
        "/accounts/entities/#{entity_id}/payment-instruments/#{instrument_id}",
        body,
        opts
      )

  @doc "List all payment instruments for a sub-entity."
  @spec list(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(entity_id, opts \\ []),
    do: Client.get("/accounts/entities/#{entity_id}/payment-instruments", opts)
end

defmodule CheckoutClient.Platforms.PayoutSchedules do
  @moduledoc "Platforms — Payout Schedules API."

  alias CheckoutClient.Client

  @doc "Get the payout schedule for a sub-entity."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(entity_id, opts \\ []),
    do: Client.get("/accounts/entities/#{entity_id}/payout-schedules", opts)

  @doc "Update the payout schedule for a sub-entity."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(entity_id, body, opts \\ []),
    do: Client.put("/accounts/entities/#{entity_id}/payout-schedules", body, opts)
end

defmodule CheckoutClient.Platforms.ReserveRules do
  @moduledoc "Platforms — Reserve Rules API."

  alias CheckoutClient.Client

  @doc "Add a reserve rule for a sub-entity."
  @spec add(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def add(entity_id, body, opts \\ []),
    do: Client.post("/accounts/entities/#{entity_id}/reserve-rules", body, opts)

  @doc "Get a specific reserve rule."
  @spec get(String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(entity_id, rule_id, opts \\ []),
    do: Client.get("/accounts/entities/#{entity_id}/reserve-rules/#{rule_id}", opts)

  @doc "Update a reserve rule."
  @spec update(String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(entity_id, rule_id, body, opts \\ []),
    do: Client.put("/accounts/entities/#{entity_id}/reserve-rules/#{rule_id}", body, opts)

  @doc "List all reserve rules for a sub-entity."
  @spec list(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(entity_id, opts \\ []),
    do: Client.get("/accounts/entities/#{entity_id}/reserve-rules", opts)
end
