# PhxExRay

> _The first x is silent_

[![Hex.pm](https://img.shields.io/hexpm/v/phx_ex_ray.svg)](https://hex.pm/packages/phx_ex_ray)

Wrapper around [ex_ray](https://github.com/derailed/ex_ray) for OpenTrace in Elixir Phoenix. Initial implementation based on the [ex_ray_tracers](https://github.com/derailed/ex_ray_tracers) example.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `phx_ex_ray` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phx_ex_ray, "~> 0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/phx_ex_ray](https://hexdocs.pm/phx_ex_ray).

## Usage

Configure [otter](https://github.com/Bluehouse-Technology/otter):

```elixir
config :otter,
  zipkin_collector_uri:    'http://127.0.0.1:9411/api/v1/spans',
  zipkin_tag_host_service: "MyApp"
```

> `zipkin_collector_uri` must be a char list

Configure application:

```elixir
# application.ex

...
ExRay.Store.create()
...
```

### Plug Usage

```elixir
# lib/my_app/endpoint.ex

...
plug PhxExRay.Tracing.Plug
...
```

### Controller Usage

Cross controller set up:

```elixir
# lib/my_app/my_app_web.ex

def controller do
  quote do
    ...
    import PhxExRay.Span
    ...
  end
end
```

Then in a specific controller:

```elixir
use PhxExRay.Span, :controller

@trace kind: :action
def index(conn, _params) do
  ...
end
```

### Database Context Usage

In a context, or any file where you use `alias MyApp.Repo`:

```elixir
use PhxExRay.Span, {:context, MyApp.Repo}

...
@trace query: :list_all_users, kind: :all, queryable: User
def list_users() do
  Repo.all(User)
end

# or

@trace query: :get_user_or_explode, sql: "SELECT * FROM users WHERE (id = X)"
def get_user!(id), do: Repo.get!(User, id)
```

### Http Client Usage

[ex_ray](https://github.com/derailed/ex_ray#installation) provides integration for http client tracing. Additional config required to specific which http client you want to use:

```elixir
config :otter,
  ...
  http_client: (:ibrowse|:httpc|:hackney)
```
