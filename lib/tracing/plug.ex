defmodule PhxExRay.Tracing.Plug do
  alias PhxExRay.Tracing.Phx
  alias ExRay.Span

  def init(default), do: default

  def call(conn, _) do
    Process.put(:request_id, conn |> Phx.request_id)

    conn
    |> Phx.span_name
    |> Span.open(conn |> Phx.request_id)
    |> :otter.tag(:component, "router")

    conn
  end

end
