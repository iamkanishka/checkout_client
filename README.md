# CheckoutClient

Production-grade Elixir client for the Checkout.com API.

Covers a wide range of APIs including Payments, Flow, Disputes, Instruments, Customers, Tokens, Workflows, Transfers, Balances, Forex, Card Issuing, Platforms, Reports, Financial Actions, Network Tokens, Identity Verification, Apple Pay, Google Pay, Forward, Compliance, and Agentic Commerce.

---

## Features

- OAuth 2.0 authentication with automatic token refresh
- Idempotent request handling
- Exponential backoff retry strategy
- HTTP/2 support via Finch
- AWS PrivateLink support
- Mutual TLS (mTLS)
- Telemetry instrumentation
- Mox-compatible behaviours for testing

---

## Installation

Add `checkout_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:checkout_client, "~> 1.0"}
  ]
end
```

---

## Configuration

Configure the client in `config/runtime.exs`:

```elixir
config :checkout_client,
  prefix:            System.fetch_env!("CHECKOUT_PREFIX"),
  access_key_id:     System.get_env("CHECKOUT_ACCESS_KEY_ID"),
  access_key_secret: System.get_env("CHECKOUT_ACCESS_KEY_SECRET"),
  environment:       :sandbox
```

---

## Quick Start

Make your first payment:

```elixir
{:ok, payment} =
  CheckoutClient.Payments.request(%{
    amount:    1000,
    currency:  "GBP",
    source:    %{type: "token", token: "tok_..."},
    reference: "my-first-payment"
  })
```

---

## Project Info

- Version: 1.0.0
- Elixir: ~> 1.18
- Source: https://github.com/iamkanishka/checkout_client
- Docs: https://hexdocs.pm/checkout_client

---

## Development

Install dependencies and compile:

```bash
mix setup
```

Run checks:

```bash
mix check
```

Run tests:

```bash
mix test
```

Run full test suite (including integration):

```bash
mix test.all
```

---

## License

MIT License

---

## Links

- GitHub: https://github.com/iamkanishka/checkout_client
- Checkout.com Docs: https://www.checkout.com/docs/developer-resources/api
- API Reference: https://api-reference.checkout.com
