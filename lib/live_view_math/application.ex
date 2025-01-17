defmodule LiveViewMath.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveViewMathWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:live_view_math, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveViewMath.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LiveViewMath.Finch},
      # Start a worker by calling: LiveViewMath.Worker.start_link(arg)
      # {LiveViewMath.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveViewMathWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveViewMath.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveViewMathWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
