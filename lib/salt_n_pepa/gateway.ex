defmodule SaltNPepa.Gateway do
  @moduledoc """
  TODO
  """
  require Logger
  use GenStage

  def push_it(), do: GenServer.call(__MODULE__, :recv)

  def start_link(init_args) do
    GenStage.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(init_args) do
    state = %{
      port: Keyword.fetch!(init_args, :port),
      delivery: Keyword.get(init_args, :delivery, :binary),
      batch_size: Keyword.get(init_args, :batch_size, 100),
      socket: nil,
      queue: []
    }

    {:ok, socket} = :gen_udp.open(state.port, [state.delivery, active: state.batch_size])

    {:producer, %{state | socket: socket}}
  end

  def handle_demand(demand, state) do
    :ok = :inet.setopts(state.socket, active: demand)

    {:noreply, [], %{state | batch_size: demand}}
  end

  def handle_info(
        {:udp, _socket, _host, _in_port, payload},
        %{queue: queue, batch_size: size} = state
      )
      when length(queue) + 1 >= size do
    {:noreply, Enum.reverse([payload | queue]), %{state | queue: []}}
  end

  def handle_info({:udp, _socket, _host, _in_port, payload}, state) do
    {:noreply, [], %{state | queue: [payload | state.queue]}}
  end

  def handle_info({:udp_passive, socket}, state) do
    Logger.info("Socket #{inspect(socket)} entering passive mode")

    {:noreply, [], state}
  end

  def handle_call(:recv, _from, state) do
    messages = :gen_udp.recv(state.socket, 0)

    Logger.info("received : #{inspect(messages)} from the socket")

    {:reply, messages, [], state}
  end
end
