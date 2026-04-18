defmodule CheckoutClient.Disputes do
  @moduledoc "Disputes API — full chargeback and dispute lifecycle management."

  alias CheckoutClient.Client

  @doc "List disputes with optional filters."
  @spec list(keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(opts \\ []), do: Client.get("/disputes", opts)

  @doc "Get full details of a single dispute."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(dispute_id, opts \\ []), do: Client.get("/disputes/#{dispute_id}", opts)

  @doc "Accept/concede a dispute without contesting."
  @spec accept(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def accept(dispute_id, opts \\ []),
    do: Client.post("/disputes/#{dispute_id}/accept", %{}, opts)

  @doc "Set dispute evidence fields and file references."
  @spec provide_evidence(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def provide_evidence(dispute_id, body, opts \\ []),
    do: Client.put("/disputes/#{dispute_id}/evidence", body, opts)

  @doc "Get currently set dispute evidence."
  @spec get_evidence(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_evidence(dispute_id, opts \\ []),
    do: Client.get("/disputes/#{dispute_id}/evidence", opts)

  @doc "Submit evidence to the card scheme."
  @spec submit_evidence(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def submit_evidence(dispute_id, opts \\ []),
    do: Client.post("/disputes/#{dispute_id}/evidence/submit", %{}, opts)

  @doc "Submit arbitration evidence after a first chargeback loss."
  @spec submit_arbitration_evidence(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def submit_arbitration_evidence(dispute_id, opts \\ []),
    do: Client.post("/disputes/#{dispute_id}/evidence/arbitration/submit", %{}, opts)

  @doc "Get submitted arbitration evidence."
  @spec get_submitted_arbitration_evidence(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_submitted_arbitration_evidence(dispute_id, opts \\ []),
    do: Client.get("/disputes/#{dispute_id}/evidence/arbitration/submitted", opts)

  @doc "Get previously submitted evidence."
  @spec get_submitted_evidence(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_submitted_evidence(dispute_id, opts \\ []),
    do: Client.get("/disputes/#{dispute_id}/evidence/submitted", opts)

  @doc "Get scheme-provided files for this dispute."
  @spec get_scheme_files(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_scheme_files(dispute_id, opts \\ []),
    do: Client.get("/disputes/#{dispute_id}/schemefiles", opts)

  @doc "Upload an evidence file."
  @spec upload_file(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def upload_file(body, opts \\ []), do: Client.post("/files", body, opts)

  @doc "Get metadata for a previously uploaded file."
  @spec get_file(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_file(file_id, opts \\ []), do: Client.get("/files/#{file_id}", opts)
end

defmodule CheckoutClient.Workflows do
  @moduledoc "Workflows API — event-driven notification rules and actions."

  alias CheckoutClient.Client

  @doc "List all workflows."
  @spec list(keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(opts \\ []), do: Client.get("/workflows", opts)

  @doc "Create a workflow."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/workflows", body, opts)

  @doc "Get a workflow by ID."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(workflow_id, opts \\ []), do: Client.get("/workflows/#{workflow_id}", opts)

  @doc "Patch (partial update) a workflow."
  @spec patch(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def patch(workflow_id, body, opts \\ []),
    do: Client.patch("/workflows/#{workflow_id}", body, opts)

  @doc "Remove a workflow."
  @spec delete(String.t(), keyword()) :: {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def delete(workflow_id, opts \\ []),
    do: Client.delete("/workflows/#{workflow_id}", opts)

  @doc "Add an action to a workflow."
  @spec add_action(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def add_action(workflow_id, body, opts \\ []),
    do: Client.post("/workflows/#{workflow_id}/actions", body, opts)

  @doc "Update an action on a workflow."
  @spec update_action(String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update_action(workflow_id, action_id, body, opts \\ []),
    do: Client.put("/workflows/#{workflow_id}/actions/#{action_id}", body, opts)

  @doc "Remove an action from a workflow."
  @spec remove_action(String.t(), String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def remove_action(workflow_id, action_id, opts \\ []),
    do: Client.delete("/workflows/#{workflow_id}/actions/#{action_id}", opts)

  @doc "Add a condition to a workflow."
  @spec add_condition(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def add_condition(workflow_id, body, opts \\ []),
    do: Client.post("/workflows/#{workflow_id}/conditions", body, opts)

  @doc "Update a condition on a workflow."
  @spec update_condition(String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update_condition(workflow_id, condition_id, body, opts \\ []),
    do: Client.put("/workflows/#{workflow_id}/conditions/#{condition_id}", body, opts)

  @doc "Remove a condition from a workflow."
  @spec remove_condition(String.t(), String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, CheckoutClient.Error.t()}
  def remove_condition(workflow_id, condition_id, opts \\ []),
    do: Client.delete("/workflows/#{workflow_id}/conditions/#{condition_id}", opts)

  @doc "Test a workflow with a synthetic event."
  @spec test(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def test(workflow_id, body, opts \\ []),
    do: Client.post("/workflows/#{workflow_id}/test", body, opts)

  @doc "Get all available event types."
  @spec event_types(keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def event_types(opts \\ []), do: Client.get("/workflows/event-types", opts)

  @doc "Get a workflow event."
  @spec get_event(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_event(event_id, opts \\ []),
    do: Client.get("/workflows/events/#{event_id}", opts)

  @doc "Get action invocations for an event."
  @spec get_action_invocations(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_action_invocations(event_id, opts \\ []),
    do: Client.get("/workflows/events/#{event_id}/actions", opts)

  @doc "Get all events for a subject (e.g., a payment ID)."
  @spec get_subject_events(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_subject_events(subject_id, opts \\ []),
    do: Client.get("/workflows/subjects/#{subject_id}/events", opts)

  @doc "Reflow a single event."
  @spec reflow_by_event(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def reflow_by_event(event_id, opts \\ []),
    do: Client.post("/workflows/events/#{event_id}/reflow", %{}, opts)

  @doc "Reflow a single event through a specific workflow."
  @spec reflow_by_event_and_workflow(String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def reflow_by_event_and_workflow(event_id, workflow_id, opts \\ []),
    do: Client.post("/workflows/events/#{event_id}/workflow/#{workflow_id}/reflow", %{}, opts)

  @doc "Reflow multiple events in bulk."
  @spec reflow(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def reflow(body, opts \\ []), do: Client.post("/workflows/events/reflow", body, opts)

  @doc "Reflow all events for a subject."
  @spec reflow_by_subject(String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def reflow_by_subject(subject_id, opts \\ []),
    do: Client.post("/workflows/subjects/#{subject_id}/reflow", %{}, opts)

  @doc "Reflow all events for a subject through a specific workflow."
  @spec reflow_by_subject_and_workflow(String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def reflow_by_subject_and_workflow(subject_id, workflow_id, opts \\ []),
    do:
      Client.post(
        "/workflows/subjects/#{subject_id}/workflow/#{workflow_id}/reflow",
        %{},
        opts
      )
end

defmodule CheckoutClient.Reports do
  @moduledoc "Reports API — retrieve programmatic financial reports."

  alias CheckoutClient.Client

  @doc "List all available reports."
  @spec list(keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(opts \\ []), do: Client.get("/reporting/reports", opts)

  @doc "Get report metadata."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(report_id, opts \\ []), do: Client.get("/reporting/reports/#{report_id}", opts)

  @doc "Download a report file."
  @spec get_file(String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_file(report_id, file_id, opts \\ []),
    do: Client.get("/reporting/reports/#{report_id}/files/#{file_id}", opts)
end

defmodule CheckoutClient.FinancialActions do
  @moduledoc "Financial Actions API — granular transaction-level financial records."

  alias CheckoutClient.Client

  @doc "Get financial actions with optional date/entity/type filters."
  @spec list(keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list(opts \\ []), do: Client.get("/reporting/statements", opts)
end
