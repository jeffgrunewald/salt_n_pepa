defmodule SampleProcessor do
  def wrap(message) do
    time = DateTime.utc_now()
    {%{payload: message, timestamp: time}, time |> DateTime.to_unix}
  end

  def encode({payload, time}) do
    {Jason.encode!(payload), time}
  end
end

defmodule SampleReducer do
  def filter({_payload, time}) do
    rem(time, 2) == 0
  end
end

defmodule SampleDispatcher do
  def log({payload, _time}) do
    IO.puts(payload)
  end
end

defmodule UdpSourceSocket do
  use GenServer

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def init(port) do
    {:ok, socket} = :gen_udp.open(port - 1)

    :timer.send_interval(100, :push_message)

    {:ok, %{socket: socket, port: port}}
  end

  def handle_info(:push_message, %{socket: socket, port: port} = state) do
    length = :crypto.rand_uniform(0, 25)
    message = :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)

    :gen_udp.send(socket, {127,0,0,1}, port, message)

    {:noreply, state}
  end
end
