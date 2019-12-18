defmodule SaltNPepa.Supervisor do
  @moduledoc """
  config :myapp, :salt_n_pepa,
    port: 5555,
    delivery: :binary,
    batch_size: 50,
    processor: %{
      handlers: [
        {Jason, :decode!, []}
      ],
      max: 50,
      min: 25
    },
    reducer: %{
      handlers: [
        {MyApp.Filter, :dedup, []}
      ],
      max: 50,
      min: 25
    },
    dispatcher: %{
      handlers: [
        {MyApp.Publisher, :send, []}
      ],
      max: 50,
      min: 25
    }
  """

  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(init_args) do
    processor = Keyword.get(init_args, :processor)
    reducer = Keyword.get(init_args, :reducer)
    dispatcher = Keyword.fetch!(init_args, :dispatcher)
    batch_size = Keyword.get(init_args, :batch_size, 100)
    min_batch = Keyword.get(init_args, :min_batch, 0.75)
    default_demand = default_demand(batch_size, min_batch)

    children =
      [
        {DynamicSupervisor, strategy: :one_for_one, name: SaltNPepa.TCPSocket.AcceptorSupervisor},
        {SaltNPepa.TCPSocket, init_args},
        {SaltNPepa.TCPSocket.Listener, init_args},
        # {SaltNPepa.Gateway, init_args},
        processor_spec(processor, default_demand),
        reducer_spec(reducer, processor, default_demand),
        dispatcher_spec(dispatcher, processor, reducer, default_demand)
      ]
      |> List.flatten()

    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp processor_spec(nil, _), do: []

  defp processor_spec(processor, default_demand) do
    config =
      processor
      |> add_demands(default_demand)
      |> Map.put(:subscription, SaltNPepa.Gateway)

    {SaltNPepa.Processor, config}
  end

  defp reducer_spec(nil, _, _), do: []

  defp reducer_spec(reducer, processor, default_demand) do
    subscription =
      case processor do
        nil -> SaltNPepa.Gateway
        _ -> SaltNPepa.Processor
      end

    config =
      reducer
      |> add_demands(default_demand)
      |> Map.put(:subscription, subscription)

    {SaltNPepa.Reducer, config}
  end

  defp dispatcher_spec(dispatcher, processor, reducer, default_demand) do
    subscription =
      case {processor, reducer} do
        {_, config} when config != nil -> SaltNPepa.Reducer
        {config, nil} when config != nil -> SaltNPepa.Processor
        {nil, nil} -> SaltNPepa.TCPSocket
        # {nil, nil} -> SaltNPepa.Gateway
      end

    config =
      dispatcher
      |> add_demands(default_demand)
      |> Map.put(:subscription, subscription)

    {SaltNPepa.Dispatcher, config}
  end

  defp add_demands(config, {max_default, min_default}) do
    config
    |> Map.update(:max, max_default, fn max -> max end)
    |> Map.update(:min, min_default, fn min -> min end)
  end

  defp default_demand(max, min) when is_float(min) do
    {max, (max * min) |> trunc()}
  end

  defp default_demand(max, min) when is_integer(min), do: {max, min}
end
