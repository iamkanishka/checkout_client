defmodule CheckoutClient.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_, _) do
    config = load_config()

    children = [
      {Finch, name: CheckoutClient.Finch, pools: finch_pools(config)},
      CheckoutClient.Auth.TokenStore
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CheckoutClient.Supervisor)
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  @spec load_config() :: map()
  defp load_config do
    :checkout_client
    |> Application.get_all_env()
    |> Map.new()
  rescue
    _ -> %{}
  end

  # Return type tightened to match Dialyzer's success typing and eliminate the
  # contract_supertype warning: keys are atom | String.t(), values are keyword lists.
  @spec finch_pools(map()) :: %{required(atom() | String.t()) => keyword()}
  defp finch_pools(%{pool_size: size, pool_count: count}) do
    %{
      :default => [size: size, count: count, protocol: :http2],
      "https://access.checkout.com" => [size: 2, count: 1],
      "https://access.sandbox.checkout.com" => [size: 2, count: 1]
    }
  end

  defp finch_pools(_), do: %{default: [size: 10, count: 1, protocol: :http2]}
end
