defmodule CheckoutClient.ErrorTest do
  use ExUnit.Case, async: true

  alias CheckoutClient.Error

  describe "from_response/4" do
    test "400 → :validation_error" do
      err = Error.from_response(400, %{"message" => "bad", "error_codes" => ["f_required"]})
      assert err.type == :validation_error
      assert err.status == 400
      assert err.error_codes == ["f_required"]
    end

    test "401 → :auth_error" do
      assert Error.from_response(401, %{}).type == :auth_error
    end

    test "403 → :auth_error" do
      assert Error.from_response(403, %{}).type == :auth_error
    end

    test "404 → :not_found" do
      assert Error.from_response(404, %{}).type == :not_found
    end

    test "409 → :conflict" do
      assert Error.from_response(409, %{}).type == :conflict
    end

    test "422 → :validation_error" do
      err = Error.from_response(422, %{"error_codes" => ["amount_invalid"]})
      assert err.type == :validation_error
      assert "amount_invalid" in err.error_codes
    end

    test "429 → :rate_limited" do
      err = Error.from_response(429, nil)
      assert err.type == :rate_limited
      assert err.status == 429
    end

    test "500 → :server_error" do
      assert Error.from_response(500, %{}).type == :server_error
    end

    test "extracts request_id from headers" do
      err = Error.from_response(400, %{}, [{"cko-request-id", "req_abc"}])
      assert err.request_id == "req_abc"
    end

    test "stores idempotency_key" do
      err = Error.from_response(409, %{}, [], "my-key")
      assert err.idempotency_key == "my-key"
    end

    test "parses JSON string body" do
      body = Jason.encode!(%{"message" => "parsed"})
      assert Error.from_response(400, body).message == "parsed"
    end

    test "handles nil body" do
      err = Error.from_response(500, nil)
      assert is_binary(err.message)
      assert err.error_codes == []
    end
  end

  describe "network_error/1" do
    test "type is :network_error with nil status" do
      err = Error.network_error(%{reason: :timeout})
      assert err.type == :network_error
      assert is_nil(err.status)
    end
  end

  describe "new/2" do
    test "builds typed error" do
      err = Error.new(:auth_error, "no creds")
      assert err.type == :auth_error
      assert err.message == "no creds"
    end
  end

  describe "Exception.message/1" do
    test "includes status and codes" do
      err = %Error{
        type: :validation_error,
        status: 422,
        message: "Invalid",
        error_codes: ["too_small"],
        request_id: "req_1",
        idempotency_key: nil,
        error_type: nil,
        raw: nil
      }

      msg = Exception.message(err)
      assert msg =~ "Invalid"
      assert msg =~ "422"
      assert msg =~ "too_small"
      assert msg =~ "req_1"
    end
  end

  describe "raise/rescue" do
    test "can be raised and rescued" do
      result =
        try do
          raise Error.new(:not_found, "missing")
        rescue
          %Error{type: :not_found} = e -> {:ok, e.message}
        end

      assert {:ok, "missing"} = result
    end
  end
end

defmodule CheckoutClient.ConfigTest do
  use ExUnit.Case, async: true

  alias CheckoutClient.Config

  describe "api_base_url/1" do
    test "production without PrivateLink" do
      config = %{environment: :production, prefix: "abcd1234", private_link: false}
      assert Config.api_base_url(config) == "https://abcd1234.api.checkout.com"
    end

    test "sandbox without PrivateLink" do
      config = %{environment: :sandbox, prefix: "abcd1234", private_link: false}
      assert Config.api_base_url(config) == "https://abcd1234.api.sandbox.checkout.com"
    end

    test "production with PrivateLink" do
      config = %{environment: :production, prefix: "abcd1234", private_link: true}
      assert Config.api_base_url(config) == "https://pl-abcd1234.api.checkout.com"
    end

    test "sandbox with PrivateLink" do
      config = %{environment: :sandbox, prefix: "abcd1234", private_link: true}
      assert Config.api_base_url(config) == "https://pl-abcd1234.api.sandbox.checkout.com"
    end
  end

  describe "auth_url/1" do
    test "production" do
      config = %{environment: :production, prefix: "abcd1234"}
      assert Config.auth_url(config) == "https://abcd1234.access.checkout.com/connect/token"
    end

    test "sandbox" do
      config = %{environment: :sandbox, prefix: "abcd1234"}
      assert Config.auth_url(config) =~ "sandbox"
    end
  end

  describe "oauth_configured?/1" do
    test "true when both fields are strings" do
      assert Config.oauth_configured?(%{access_key_id: "ack_1", access_key_secret: "s"})
    end

    test "false when id is nil" do
      refute Config.oauth_configured?(%{access_key_id: nil, access_key_secret: "s"})
    end

    test "false when secret is nil" do
      refute Config.oauth_configured?(%{access_key_id: "ack_1", access_key_secret: nil})
    end
  end

  describe "secret_key_configured?/1" do
    test "true for binary" do
      assert Config.secret_key_configured?(%{secret_key: "sk_sbox_..."})
    end

    test "false for nil" do
      refute Config.secret_key_configured?(%{secret_key: nil})
    end
  end
end

defmodule CheckoutClient.HTTP.IdempotencyTest do
  use ExUnit.Case, async: true

  alias CheckoutClient.HTTP.Idempotency

  describe "required?/2" do
    test "POST /payments is idempotent" do
      assert Idempotency.required?(:post, "/payments")
    end

    test "POST /payments/:id/captures is idempotent" do
      assert Idempotency.required?(:post, "/payments/pay_1/captures")
    end

    test "POST /payment-contexts is idempotent" do
      assert Idempotency.required?(:post, "/payment-contexts")
    end

    test "POST /transfers is idempotent" do
      assert Idempotency.required?(:post, "/transfers")
    end

    test "GET /payments is not idempotent" do
      refute Idempotency.required?(:get, "/payments")
    end

    test "POST /customers is not idempotent" do
      refute Idempotency.required?(:post, "/customers")
    end

    test "DELETE is not idempotent" do
      refute Idempotency.required?(:delete, "/payments/pay_1")
    end
  end

  describe "generate/1" do
    test "generates a valid V4 UUID without prefix" do
      key = Idempotency.generate(nil)

      assert String.match?(
               key,
               ~r/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/
             )
    end

    test "prepends prefix" do
      key = Idempotency.generate("order-42")
      assert String.starts_with?(key, "order-42-")
    end

    test "generates unique keys" do
      keys = Enum.map(1..50, fn _ -> Idempotency.generate(nil) end)
      assert length(Enum.uniq(keys)) == 50
    end
  end

  describe "resolve/3" do
    test "returns explicit key when provided" do
      assert Idempotency.resolve(:post, "/payments", idempotency_key: "explicit") == "explicit"
    end

    test "auto-generates for idempotent endpoints" do
      key = Idempotency.resolve(:post, "/payments", [])
      assert is_binary(key) and byte_size(key) > 0
    end

    test "returns nil for non-idempotent endpoints" do
      assert is_nil(Idempotency.resolve(:post, "/customers", []))
    end
  end
end

defmodule CheckoutClient.HTTP.RetryTest do
  use ExUnit.Case, async: true

  alias CheckoutClient.HTTP.Retry

  describe "retryable?/1" do
    test "429 is retryable" do
      assert Retry.retryable?({:ok, %{status: 429}})
    end

    test "500 is retryable" do
      assert Retry.retryable?({:ok, %{status: 500}})
    end

    test "502, 503, 504 are retryable" do
      assert Retry.retryable?({:ok, %{status: 502}})
      assert Retry.retryable?({:ok, %{status: 503}})
      assert Retry.retryable?({:ok, %{status: 504}})
    end

    test "200 is not retryable" do
      refute Retry.retryable?({:ok, %{status: 200}})
    end

    test "400 is not retryable" do
      refute Retry.retryable?({:ok, %{status: 400}})
    end

    test "409 is not retryable" do
      refute Retry.retryable?({:ok, %{status: 409}})
    end

    test "timeout is retryable" do
      assert Retry.retryable?({:error, %{reason: :timeout}})
    end

    test "closed is retryable" do
      assert Retry.retryable?({:error, %{reason: :closed}})
    end
  end

  describe "delay/2" do
    setup do
      {:ok, config: %{retry_base_delay: 500, retry_max_delay: 30_000}}
    end

    test "attempt 0 is within base range", %{config: config} do
      delay = Retry.delay(0, config)
      assert delay >= 0
      assert delay <= 500
    end

    test "delay never exceeds max_delay", %{config: config} do
      delays = Enum.map(0..20, &Retry.delay(&1, config))
      assert Enum.all?(delays, &(&1 <= config.retry_max_delay))
    end

    test "delays have jitter (not all identical)" do
      config = %{retry_base_delay: 1_000, retry_max_delay: 30_000}
      delays = Enum.map(1..30, fn _ -> Retry.delay(5, config) end)
      assert length(Enum.uniq(delays)) > 1
    end
  end

  describe "req_opts/1" do
    test "returns retry: false when max_retries is 0" do
      opts = Retry.req_opts(%{max_retries: 0})
      assert opts[:retry] == false
    end

    test "returns retry function when max_retries > 0" do
      config = %{max_retries: 3, retry_base_delay: 500, retry_max_delay: 30_000}
      opts = Retry.req_opts(config)
      assert is_function(opts[:retry], 1)
      assert opts[:max_retries] == 3
    end
  end
end
