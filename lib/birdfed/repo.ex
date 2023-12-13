defmodule Birdfed.Repo do
  use Ecto.Repo,
    otp_app: :birdfed,
    adapter: Ecto.Adapters.SQLite3
end
