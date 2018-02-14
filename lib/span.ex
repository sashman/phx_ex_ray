defmodule PhxExRay.Span do

  alias ExRay.Span
  alias ExRay.Store
  alias PhxExRay.Tracing.Phx
  alias PhxExRay.Tracing.Ecto

  def controller do
    quote do
      use ExRay, pre: :start_span, post: :end_span

      def start_span(ctx) do
        conn = ctx.args |> List.first
        request_id = conn |> Phx.request_id
        span_name = "#{Phx.controller_name(conn)} #{Phx.action_name(conn)}"

        Process.put(:request_id, conn |> Phx.request_id)

        span_name
        |> Span.open(request_id)
        |> :otter.tag(:component, "controller")
        |> :otter.tag(:kind, ctx.meta[:kind])
        |> :otter.tag(:controller, conn |> Phx.controller_name)
        |> :otter.tag(:action    , conn |> Phx.action_name)
        |> :otter.log(">>> Starting action #{conn |> Phx.action_name} at #{conn.request_path}")
      end

      def end_span(ctx, span, _rendered) do
        conn = ctx.args |> List.first
        request_id = conn |> Phx.request_id

        controller_span = span
        |> :otter.log("<<< Ending action #{conn |> Phx.action_name}")
        |> Span.close(request_id)
        |> close_parent(request_id)
      end

      defp close_parent(controller_span, request_id) do
        case Store.current(request_id) do
          nil -> controller_span
          parent_span -> parent_span |> Span.close(request_id)
        end
      end
    end
  end

  def context(repo) do
    quote do
      use ExRay, pre: :start_span, post: :end_span

      defp request_id() do
        case Process.get(:request_id) do
          nil -> "request_id_missing"
          request_id -> request_id
        end
      end

      defp start_span(ctx) do
        ctx.target
        |> Span.open(request_id())
        |> :otter.tag(:component, "database")
        |> :otter.tag(:query, ctx.meta[:query])
        |> :otter.log(log_query_string(ctx.meta))
      end

      defp end_span(ctx, p_span, _ret) do
        p_span |> Span.close(request_id())
      end

      defp log_query_string([_, kind: kind, queryable: queryable]) do
        Ecto.to_query(kind, unquote(repo), queryable)
      end
      defp log_query_string([_, sql: string]), do: string
      defp log_query_string(_meta), do: "Query not specified"
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__({:context, repo}) do
    apply(__MODULE__, :context, [repo])
  end

end
