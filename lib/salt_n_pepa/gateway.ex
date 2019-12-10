defmodule SaltNPepa.Gateway do
  @moduledoc """
  TODO
  """
  require Logger
  use GenStage

  def push_it(), do: GenServer.call(__MODULE__, :recv)

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
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

    {:producer, %{state | socket: socket}}
  end

  def handle_info({:udp, socket, host, _in_port, payload}, state) do
    Logger.info("Received #{inspect(payload)} from #{inspect(host)} on socket #{inspect(socket)}")

    {:noreply, [], state}
  end

  def handle_info({:udp_passive, socket}, state) do
    Logger.info("Socket #{inspect(socket)} entering passive mode")

    {:noreply, [], state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  def handle_call(:recv, _from, state) do
    messages = :gen_udp.recv(state.socket, 0)

    Logger.info("received : #{inspect(messages)} from the socket")

    {:reply, messages, [], state}
  end
end
