defmodule PhxExRay.Tracing.Plug do
  alias PhxExRay.Tracing.Phx
  alias ExRay.Span

  require Logger

  def init(default), do: default

  def call(conn, _) do
    Logger.debug "Span id: #{conn |> Phx.request_id}"

    case Integer.parse(conn |> Phx.request_id, 16) do
      {parent_span_id, _} -> new_span(conn, parent_span_id)
      _ -> new_span(conn, nil)
    end

    conn
  end

  defp new_span(conn, nil) do
    Process.put(:request_id, conn |> Phx.request_id)

    conn
    |> Phx.span_name
    |> Span.open(conn |> Phx.request_id)
    |> :otter.tag(:component, "router")
  end

  defp new_span(conn, parent_span_id) do
    current_span_id = generate_request_id()
    Process.put(:request_id, current_span_id)

    Logger.debug "Using parent span id: #{parent_span_id}"
    conn
    |> Phx.span_name
    |> Span.open(current_span_id, parent_span_id)
    |> :otter.tag(:component, "router")
  end

  defp generate_request_id do
    binary = <<
      System.system_time(:nanoseconds)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>

    Base.hex_encode32(binary, case: :lower)
  end

end
