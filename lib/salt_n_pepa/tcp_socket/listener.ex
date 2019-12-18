defmodule SaltNPepa.TCPSocket.Listener do
  @moduledoc """
  TODO
  """
  use GenServer

  def start_acceptor() do
    GenServer.cast(__MODULE__, :start_acceptor)
  end

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(init_args) do
    state = %{
      port: Keyword.fetch!(init_args, :port),
      delivery: Keyword.get(init_args, :delivery, :binary),
      batch_size: Keyword.get(init_args, :batch_size, 100),
      acceptor_count: Keyword.get(init_args, :acceptor_count, 10),
      socket: nil
    }

    {:ok, socket} = :gen_tcp.listen(state.port, [state.delivery, active: state.batch_size])

    Enum.each(0..(state.acceptor_count - 1), fn _ -> start_acceptor() end)

    {:ok, %{state | socket: socket}}
  end

  def handle_cast(:start_acceptor, %{socket: socket} = state) do
    spec = {SaltNPepa.TCPSocket.Acceptor, socket}
    DynamicSupervisor.start_child(SaltNPepa.TCPSocket.AcceptorSupervisor, spec)

    {:noreply, state}
  end
end
