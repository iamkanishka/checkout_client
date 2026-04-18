# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.0.0] - 2026-04-18

### Added
- Initial release of `CheckoutClient`
- Full coverage of Checkout.com APIs:
  - Payments (including Flow, Links, Hosted Pages, Contexts, Setups, Methods)
  - Tokens, Instruments, Customers
  - Disputes, Workflows, Compliance
  - Transfers, Balances, Forex
  - Apple Pay, Google Pay integrations
  - Issuing (Cards, Cardholders, Controls, Transactions, Sandbox)
  - Platforms (Entities, Payment Instruments, Payout Schedules, Reserve Rules)
  - Reports and Financial Actions
  - Identity Verification (Applicants, AML, FaceAuth, Documents)
  - Network Tokens, Sessions, Account Updater
  - Agentic Commerce support

### Features
- OAuth 2.0 authentication with automatic token refresh
- Idempotent request handling
- Exponential backoff retry strategy
- HTTP/2 support via Finch
- AWS PrivateLink support
- Mutual TLS (mTLS)
- Telemetry instrumentation
- Mox-compatible behaviours for testing

### Developer Experience
- Structured module grouping for scalability
- Dialyzer support with strict flags
- Credo linting integration
- ExCoveralls test coverage support
- StreamData for property-based testing
- Bypass and Mox for HTTP mocking

---

## [Unreleased]

### Planned
- Additional examples and guides
- Extended documentation for advanced flows
- Performance benchmarking suite
- CLI utilities for debugging and testing