# Getting Started with CheckoutClient

## 1. Add the dependency

```elixir
def deps do
  [{:checkout_client, "~> 1.0"}]
end
```

## 2. Configure

```elixir
# config/runtime.exs
config :checkout_client,
  prefix:            System.fetch_env!("CHECKOUT_PREFIX"),
  access_key_id:     System.get_env("CHECKOUT_ACCESS_KEY_ID"),
  access_key_secret: System.get_env("CHECKOUT_ACCESS_KEY_SECRET"),
  environment:       :sandbox
```

## 3. Make your first payment

```elixir
{:ok, payment} = CheckoutClient.Payments.request(%{
  amount:    1000,
  currency:  "GBP",
  source:    %{type: "token", token: "tok_..."},
  reference: "my-first-payment"
})
```
