ExUnit.start(exclude: [:integration])

Mox.defmock(CheckoutClient.MockHTTP, for: CheckoutClient.Behaviours.HTTP)
Mox.defmock(CheckoutClient.MockAuth, for: CheckoutClient.Behaviours.Auth)
