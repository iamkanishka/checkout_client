defmodule CheckoutClient.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/iamkanishka/checkout_client"
  @description """
  Production-grade Elixir client for the Checkout.com API. Covers all APIs:
  Payments, Flow, Disputes, Instruments, Customers, Tokens, Workflows, Transfers,
  Balances, Forex, Card Issuing, Platforms, Reports, Financial Actions, Network
  Tokens, Identity Verification, Apple Pay, Google Pay, Forward, Compliance, and
  Agentic Commerce. Features: OAuth 2.0 with auto-refresh, idempotency, exponential
  backoff, AWS PrivateLink, mTLS, Telemetry, Mox-compatible behaviours.
  """

  def project do
    [
      app: :checkout_client,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: @description,
      package: package(),
      name: "checkout_client",
      source_url: @source_url,
      homepage_url: "https://hexdocs.pm/checkout_client",
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {CheckoutClient.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # HTTP — Req over Finch (HTTP/2, connection pooling)
      {:req, "~> 0.5"},
      {:finch, "~> 0.19"},
      # JSON
      {:jason, "~> 1.4"},
      # Config validation
      {:nimble_options, "~> 1.1"},
      # Observability
      {:telemetry, "~> 1.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"},
      # Dev tooling
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      # Testing
      {:bypass, "~> 2.1", only: :test},
      {:mox, "~> 1.1", only: :test},
      {:stream_data, "~> 1.1", only: :test}
    ]
  end

  defp package do
    [
      name: "checkout_client",
      files: ~w[lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "Checkout.com Docs" => "https://www.checkout.com/docs/developer-resources/api",
        "Checkout.com API Reference" => "https://api-reference.checkout.com"
      },
      maintainers: ["Your Name"]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "guides/getting_started.md"],
      groups_for_modules: [
        Core: [CheckoutClient, CheckoutClient.Client, CheckoutClient.Config, CheckoutClient.Error],
        Auth: [CheckoutClient.Auth, CheckoutClient.Auth.TokenStore],
        HTTP: [CheckoutClient.HTTP.Idempotency, CheckoutClient.HTTP.Retry],
        Behaviours: [CheckoutClient.Behaviours.HTTP, CheckoutClient.Behaviours.Auth],
        Payments: [
          CheckoutClient.Payments,
          CheckoutClient.Payments.Flow,
          CheckoutClient.Payments.Links,
          CheckoutClient.Payments.HostedPage,
          CheckoutClient.Payments.Contexts,
          CheckoutClient.Payments.Setups,
          CheckoutClient.Payments.Methods
        ],
        "Credentials & Vault": [
          CheckoutClient.Tokens,
          CheckoutClient.Instruments,
          CheckoutClient.Customers,
          CheckoutClient.Forward
        ],
        "Risk & Compliance": [
          CheckoutClient.Disputes,
          CheckoutClient.Workflows,
          CheckoutClient.Compliance
        ],
        "Funds & FX": [CheckoutClient.Transfers, CheckoutClient.Balances, CheckoutClient.Forex],
        "Wallets & Integrations": [CheckoutClient.ApplePay, CheckoutClient.GooglePay],
        Issuing: [
          CheckoutClient.Issuing.Cardholders,
          CheckoutClient.Issuing.Cards,
          CheckoutClient.Issuing.Controls,
          CheckoutClient.Issuing.ControlProfiles,
          CheckoutClient.Issuing.ControlGroups,
          CheckoutClient.Issuing.CardholderAccessTokens,
          CheckoutClient.Issuing.Transactions,
          CheckoutClient.Issuing.Disputes,
          CheckoutClient.Issuing.Sandbox
        ],
        Platforms: [
          CheckoutClient.Platforms.Entities,
          CheckoutClient.Platforms.PaymentInstruments,
          CheckoutClient.Platforms.PayoutSchedules,
          CheckoutClient.Platforms.ReserveRules
        ],
        Reporting: [CheckoutClient.Reports, CheckoutClient.FinancialActions],
        Identity: [
          CheckoutClient.Identity.Applicants,
          CheckoutClient.Identity.Verification,
          CheckoutClient.Identity.AML,
          CheckoutClient.Identity.FaceAuth,
          CheckoutClient.Identity.Documents
        ],
        Misc: [
          CheckoutClient.NetworkTokens,
          CheckoutClient.CardMetadata,
          CheckoutClient.Sessions,
          CheckoutClient.AccountUpdater,
          CheckoutClient.AgenticCommerce,
          CheckoutClient.Telemetry
        ]
      ]
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.cobertura": :test,
      "test.all": :test
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:ex_unit, :mix],
      flags: [:error_handling, :missing_return, :underspecs],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end

  defp aliases do
    [
      # check: ["format --check-formatted", "credo --strict", "dialyzer --format github", "test"],
      check: ["format --check-formatted", "credo --strict", "dialyzer --format github"],
      "test.all": ["test --include integration"],
      setup: ["deps.get", "compile"]
    ]
  end
end
