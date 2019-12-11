[![Master](https://travis-ci.org/jeffgrunewald/salt_n_pepa.svg?branch=master)](https://travis-ci.org/jeffgrunewald/salt_n_pepa)

# SaltNPepa

A library for creating data ingestion push gateways in Elixir.

SaltNPepa allows the user to create a socket listening for packets
to be pushed to, pipes the received packets through a configurable series
of modules/functions for basic serde operations, optional filter/deduping
of messages, and finally performs an egress step to send the data to its
next destination.

The name is a reference to the American hip-hop super group of the same name
for their chart-topping 1987 hit "Push It".

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `salt_n_pepa` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:salt_n_pepa, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/salt_n_pepa](https://hexdocs.pm/salt_n_pepa).
