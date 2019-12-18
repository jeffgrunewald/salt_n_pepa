defmodule SaltNPepa.TCPSocket.Acceptor do
  @moduledoc """
  TODO
  """

  use GenServer, restart: :transient

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    state = %{
      listen_socket: socket,
      accept_socket: nil
    }

    {:ok, state, {:continue, :accept}}
  end

  def handle_continue(:accept, state) do
    send(self(), :transfer)

    {:ok, accept} = :gen_tcp.accept(state.listen_socket)

    {:noreply, %{state | accept_socket: accept}}
  end

  def handle_info(:transfer, %{accept_socket: socket} = state) do
    :ok = SaltNPepa.TCPSocket.register_socket(socket)
    producer_pid = Process.whereis(SaltNPepa.TCPSocket)
    :ok = :gen_tcp.controlling_process(socket, producer_pid)
    :ok = SaltNPepa.TCPSocket.Listener.start_acceptor()

    {:stop, :shutdown, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
