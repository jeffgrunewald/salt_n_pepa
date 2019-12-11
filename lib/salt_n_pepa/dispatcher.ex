defmodule SaltNPepa.Dispatcher do
  @moduledoc """
  TODO
  """

  require Logger
  use GenStage

  def start_link(init_args) do
    GenStage.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(init_args) do
    state = %{
      handler: init_args.handler,
      subscription: init_args.subscription,
      max_demand: init_args.max,
      min_demand: init_args.min
    }

    {:consumer, state,
     subscribe_to: [
       {state.subscription, min_demand: state.min_demand, max_demand: state.max_demand}
     ]}
  end

  def handle_events(messages, _from, %{handler: handler} = state) do
    Enum.map(messages, &apply_handler(&1, handler))

    {:noreply, [], state}
  end

  def handle_info(_, state), do: {:noreply, [], state}

  defp apply_handler(message, {module, function, args}) do
    apply(module, function, [message] ++ args)
  end

  defp apply_handler(message, function) when is_function(function) do
    apply(function, [message])
  end
end
