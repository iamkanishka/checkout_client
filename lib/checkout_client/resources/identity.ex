defmodule CheckoutClient.Identity.Applicants do
  @moduledoc "Identity — Applicants API."

  alias CheckoutClient.Client

  @doc "Create an applicant."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/identity/applicants", body, opts)

  @doc "Get an applicant."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(applicant_id, opts \\ []),
    do: Client.get("/identity/applicants/#{applicant_id}", opts)

  @doc "Update an applicant."
  @spec update(String.t(), map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def update(applicant_id, body, opts \\ []),
    do: Client.patch("/identity/applicants/#{applicant_id}", body, opts)

  @doc "Anonymize an applicant (GDPR erasure). Irreversible."
  @spec anonymize(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def anonymize(applicant_id, opts \\ []),
    do: Client.post("/identity/applicants/#{applicant_id}/anonymize", %{}, opts)
end

defmodule CheckoutClient.Identity.Verification do
  @moduledoc "Identity — Identity Verification API."

  alias CheckoutClient.Client

  @doc "Create and immediately start an identity verification."
  @spec create_and_start(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create_and_start(body, opts \\ []),
    do: Client.post("/identity/verifications", body, opts)

  @doc "Create an identity verification (without starting)."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []),
    do: Client.post("/identity/verifications/create", body, opts)

  @doc "Get identity verification details."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(verification_id, opts \\ []),
    do: Client.get("/identity/verifications/#{verification_id}", opts)

  @doc "Anonymize an identity verification (GDPR)."
  @spec anonymize(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def anonymize(verification_id, opts \\ []),
    do: Client.post("/identity/verifications/#{verification_id}/anonymize", %{}, opts)

  @doc "Create a new verification attempt."
  @spec create_attempt(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create_attempt(verification_id, body, opts \\ []),
    do: Client.post("/identity/verifications/#{verification_id}/attempts", body, opts)

  @doc "List all attempts for a verification."
  @spec list_attempts(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list_attempts(verification_id, opts \\ []),
    do: Client.get("/identity/verifications/#{verification_id}/attempts", opts)

  @doc "Get a specific verification attempt."
  @spec get_attempt(String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_attempt(verification_id, attempt_id, opts \\ []),
    do:
      Client.get(
        "/identity/verifications/#{verification_id}/attempts/#{attempt_id}",
        opts
      )

  @doc "Get the PDF report for a completed verification."
  @spec get_report(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_report(verification_id, opts \\ []),
    do: Client.get("/identity/verifications/#{verification_id}/report", opts)
end

defmodule CheckoutClient.Identity.AML do
  @moduledoc "Identity — AML Screening API."

  alias CheckoutClient.Client

  @doc "Create an AML screening."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []), do: Client.post("/identity/aml-screenings", body, opts)

  @doc "Get AML screening results."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(screening_id, opts \\ []),
    do: Client.get("/identity/aml-screenings/#{screening_id}", opts)
end

defmodule CheckoutClient.Identity.FaceAuth do
  @moduledoc "Identity — Face Authentication API."

  alias CheckoutClient.Client

  @doc "Create a face authentication session."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []),
    do: Client.post("/identity/face-authentications", body, opts)

  @doc "Get face authentication details."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(auth_id, opts \\ []),
    do: Client.get("/identity/face-authentications/#{auth_id}", opts)

  @doc "Anonymize a face authentication (GDPR)."
  @spec anonymize(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def anonymize(auth_id, opts \\ []),
    do: Client.post("/identity/face-authentications/#{auth_id}/anonymize", %{}, opts)

  @doc "Create a face authentication attempt."
  @spec create_attempt(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create_attempt(auth_id, body, opts \\ []),
    do: Client.post("/identity/face-authentications/#{auth_id}/attempts", body, opts)

  @doc "List all face authentication attempts."
  @spec list_attempts(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list_attempts(auth_id, opts \\ []),
    do: Client.get("/identity/face-authentications/#{auth_id}/attempts", opts)

  @doc "Get a specific face authentication attempt."
  @spec get_attempt(String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_attempt(auth_id, attempt_id, opts \\ []),
    do:
      Client.get(
        "/identity/face-authentications/#{auth_id}/attempts/#{attempt_id}",
        opts
      )
end

defmodule CheckoutClient.Identity.Documents do
  @moduledoc "Identity — ID Document Verification API."

  alias CheckoutClient.Client

  @doc "Create an ID document verification."
  @spec create(map(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create(body, opts \\ []),
    do: Client.post("/identity/id-document-verifications", body, opts)

  @doc "Get ID document verification details."
  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get(doc_id, opts \\ []),
    do: Client.get("/identity/id-document-verifications/#{doc_id}", opts)

  @doc "Anonymize an ID document verification (GDPR)."
  @spec anonymize(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def anonymize(doc_id, opts \\ []),
    do: Client.post("/identity/id-document-verifications/#{doc_id}/anonymize", %{}, opts)

  @doc "Create a document verification attempt."
  @spec create_attempt(String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def create_attempt(doc_id, body, opts \\ []),
    do: Client.post("/identity/id-document-verifications/#{doc_id}/attempts", body, opts)

  @doc "List all attempts for a document verification."
  @spec list_attempts(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def list_attempts(doc_id, opts \\ []),
    do: Client.get("/identity/id-document-verifications/#{doc_id}/attempts", opts)

  @doc "Get a specific document verification attempt."
  @spec get_attempt(String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_attempt(doc_id, attempt_id, opts \\ []),
    do:
      Client.get(
        "/identity/id-document-verifications/#{doc_id}/attempts/#{attempt_id}",
        opts
      )

  @doc "Get the PDF report for a completed document verification."
  @spec get_report(String.t(), keyword()) :: {:ok, map()} | {:error, CheckoutClient.Error.t()}
  def get_report(doc_id, opts \\ []),
    do: Client.get("/identity/id-document-verifications/#{doc_id}/report", opts)
end
