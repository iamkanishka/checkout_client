# Suppress known false positives only — keep this list minimal.
[
  # NimbleOptions uses dynamic dispatch Dialyzer cannot follow
  ~r/NimbleOptions\.validate!/,
  # Bypass is test-only and carries loose specs
  ~r/Bypass\./
]
