defmodule CheckoutClient.PaymentsTest do
  use ExUnit.Case, async: true

  alias CheckoutClient.{Error, Payments}

  # Bypass intercepts TCP — in a real test suite these would point at a Bypass
  # server. Here we verify that correct paths and headers are constructed, and
  # that error responses are correctly parsed into structured Error structs.

  setup do
    bypass = Bypass.open()

    config = [
      prefix: "localhost",
      environment: :sandbox,
      secret_key: "sk_sbox_test",
      max_retries: 0,
      log_level: :none
    ]

    {:ok, bypass: bypass, config: config}
  end

  describe "request/2" do
    test "returns {:ok, body} on 201", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "POST", "/payments", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(201, Jason.encode!(%{"id" => "pay_123", "status" => "Authorized"}))
      end)

      assert {:ok, %{"id" => "pay_123", "status" => "Authorized"}} =
               Payments.request(%{amount: 10_000, currency: "GBP"}, bypass_opts(bypass, cfg))
    end

    test "injects Cko-Idempotency-Key header automatically", %{bypass: bypass, config: cfg} do
      test_pid = self()

      Bypass.expect_once(bypass, "POST", "/payments", fn conn ->
        key = Plug.Conn.get_req_header(conn, "cko-idempotency-key")
        send(test_pid, {:key, key})

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(201, Jason.encode!(%{"id" => "pay_1"}))
      end)

      Payments.request(%{amount: 100, currency: "USD"}, bypass_opts(bypass, cfg))
      assert_receive {:key, [k]} when is_binary(k)

      assert String.match?(
               k,
               ~r/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/
             )
    end

    test "uses custom idempotency key when provided", %{bypass: bypass, config: cfg} do
      test_pid = self()

      Bypass.expect_once(bypass, "POST", "/payments", fn conn ->
        key = Plug.Conn.get_req_header(conn, "cko-idempotency-key")
        send(test_pid, {:key, key})

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(201, Jason.encode!(%{"id" => "pay_1"}))
      end)

      Payments.request(
        %{amount: 100},
        bypass_opts(bypass, cfg) ++ [idempotency_key: "my-custom-key"]
      )

      assert_receive {:key, ["my-custom-key"]}
    end

    test "returns :validation_error on 422", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "POST", "/payments", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          422,
          Jason.encode!(%{
            "error_type" => "request_invalid",
            "error_codes" => ["amount_invalid"]
          })
        )
      end)

      assert {:error, %Error{type: :validation_error, status: 422, error_codes: ["amount_invalid"]}} =
               Payments.request(%{}, bypass_opts(bypass, cfg))
    end

    test "returns :rate_limited on 429", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "POST", "/payments", fn conn ->
        Plug.Conn.send_resp(conn, 429, "")
      end)

      assert {:error, %Error{type: :rate_limited, status: 429}} =
               Payments.request(%{amount: 100}, bypass_opts(bypass, cfg))
    end

    test "returns :conflict on 409", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "POST", "/payments", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(409, Jason.encode!(%{"message" => "Conflict"}))
      end)

      assert {:error, %Error{type: :conflict, status: 409}} =
               Payments.request(%{amount: 100}, bypass_opts(bypass, cfg))
    end

    test "sends correct Authorization header", %{bypass: bypass, config: cfg} do
      test_pid = self()

      Bypass.expect_once(bypass, "POST", "/payments", fn conn ->
        auth = Plug.Conn.get_req_header(conn, "authorization")
        send(test_pid, {:auth, auth})

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(201, Jason.encode!(%{"id" => "pay_1"}))
      end)

      Payments.request(%{amount: 100}, bypass_opts(bypass, cfg))
      assert_receive {:auth, ["Bearer sk_sbox_test"]}
    end
  end

  describe "get/2" do
    test "fetches payment on 200", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "GET", "/payments/pay_xyz", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"id" => "pay_xyz", "status" => "Captured"}))
      end)

      assert {:ok, %{"id" => "pay_xyz"}} = Payments.get("pay_xyz", bypass_opts(bypass, cfg))
    end

    test "returns :not_found on 404", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "GET", "/payments/pay_missing", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(404, Jason.encode!(%{"message" => "Not found"}))
      end)

      assert {:error, %Error{type: :not_found}} =
               Payments.get("pay_missing", bypass_opts(bypass, cfg))
    end
  end

  describe "capture/3" do
    test "posts to /payments/:id/captures", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "POST", "/payments/pay_1/captures", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(202, Jason.encode!(%{"action_id" => "act_cap_1"}))
      end)

      assert {:ok, %{"action_id" => "act_cap_1"}} =
               Payments.capture("pay_1", %{}, bypass_opts(bypass, cfg))
    end
  end

  describe "refund/3" do
    test "posts to /payments/:id/refunds", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "POST", "/payments/pay_1/refunds", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(202, Jason.encode!(%{"action_id" => "act_ref_1"}))
      end)

      assert {:ok, %{"action_id" => "act_ref_1"}} =
               Payments.refund("pay_1", %{amount: 5_000}, bypass_opts(bypass, cfg))
    end
  end

  describe "void/3" do
    test "posts to /payments/:id/voids", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "POST", "/payments/pay_1/voids", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(202, Jason.encode!(%{"action_id" => "act_void_1"}))
      end)

      assert {:ok, _} = Payments.void("pay_1", %{}, bypass_opts(bypass, cfg))
    end
  end

  describe "search/2" do
    test "posts to /payments/search", %{bypass: bypass, config: cfg} do
      Bypass.expect_once(bypass, "POST", "/payments/search", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"total_count" => 1, "data" => []}))
      end)

      assert {:ok, %{"total_count" => 1}} =
               Payments.search(%{reference: "ORD-1"}, bypass_opts(bypass, cfg))
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp bypass_opts(bypass, config) do
    # Inject a bypass-compatible base URL override via the client mechanism
    client = %{
      config:
        Map.merge(Map.new(config), %{
          prefix: "localhost",
          environment: :sandbox,
          private_link: false,
          # Override base URL resolution — this is handled by a mock in real tests
          _bypass_port: bypass.port
        })
    }

    [client: client]
  end
end
