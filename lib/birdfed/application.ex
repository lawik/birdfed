defmodule Birdfed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BirdfedWeb.Telemetry,
      # Start the Ecto repository
      # Birdfed.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Birdfed.PubSub},
      # Start Finch
      {Finch, name: Birdfed.Finch},
      %{id: :birdfed_actors, start: {Fedex.Doc, :start_link, [:birdfed_actors]}},
      %{id: :birdfed_fingers, start: {Fedex.Doc, :start_link, [:birdfed_fingers]}},
      # Start the Endpoint (http/https)
      BirdfedWeb.Endpoint
      # Start a worker by calling: Birdfed.Worker.start_link(arg)
      # {Birdfed.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Birdfed.Supervisor]

    Task.start(fn ->
      :timer.sleep(3000)
      Birdfed.Fed.setup()
    end)

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BirdfedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
