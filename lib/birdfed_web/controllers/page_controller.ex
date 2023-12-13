defmodule BirdfedWeb.PageController do
  use BirdfedWeb, :controller

  def home(conn, _params) do
    IO.inspect(conn, label: "passed signature verification and all")
    json(conn, %{status: "you aight"})
  end

  # def missing(conn, _params), do: conn
end
