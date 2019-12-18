defmodule SaltNPepa.TCPSocket do
  @moduledoc """
  TODO
  """
  require Logger
  use GenStage

  def register_socket(socket) do
    GenServer.cast(__MODULE__, {:register, socket})
  end

  def start_link(init_args) do
    GenStage.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(init_args) do
    state = %{
      port: Keyword.fetch!(init_args, :port),
      batch_size: Keyword.get(init_args, :batch_size, 100),
      queues: %{}
    }

    {:producer, state}
  end

  def handle_demand(demand, state) do
    {:noreply, [], %{state | batch_size: demand}}
  end

  def handle_info({:tcp, socket, payload}, state) do
    dispatch_events(socket, payload, state)
  end

  def handle_info({:tcp_closed, socket}, %{queues: queues} = state) do
    Logger.info("Connection to socket #{inspect(socket)} closed from client")

    new_queues = Map.delete(queues, socket)
    {:noreply, [], %{state | queues: new_queues}}
  end

  def handle_info({:tcp_passive, socket}, state) do
    Logger.info("Socket #{inspect(socket)} entering passive mode")

    {:noreply, [], state}
  end

  def handle_cast({:register, socket}, %{queues: queues} = state) do
    {:noreply, [], %{state | queues: Map.put(queues, socket, [])}}
  end

  defp dispatch_events(socket, payload, %{queues: queues, batch_size: size} = state) do
    case length(queues[socket]) + 1 >= size do
      true ->
        :ok = :inet.setopts(socket, active: size)
        new_queues = Map.put(queues, socket, [])
        {:noreply, Enum.reverse([payload | queues[socket]]), %{state | queues: new_queues}}

      false ->
        new_queues = Map.put(queues, socket, [payload | queues[socket]])
        {:noreply, [], %{state | queues: new_queues}}
    end
  end
end
