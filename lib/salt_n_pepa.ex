defmodule SaltNPepa do
  @moduledoc """
  TODO
  """
  require Logger
  use GenServer

  def push_it(), do: GenServer.call(__MODULE__, :recv)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    state = %{
      port: Keyword.fetch!(args, :port),
      batch_size: Keyword.get(args, :batch_size, 1_000_000),
      delivery: Keyword.get(args, :delivery, :binary),
      active: Keyword.get(args, :active, 10),
      socket: nil
    }

    {:ok, socket} = :gen_udp.open(state.port, [state.delivery, active: state.active])

    {:ok, %{state | socket: socket}}
  end

  def handle_call(:recv, _from, state) do
    messages = :gen_udp.recv(state.socket, 0)

    Logger.info("received : #{inspect(messages)} from the socket")

    {:reply, messages, state}
  end
end
