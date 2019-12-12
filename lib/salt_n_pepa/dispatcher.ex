defmodule SaltNPepa.Dispatcher do
  @moduledoc """
  TODO
  """

  use GenStage

  def start_link(init_args) do
    GenStage.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(init_args) do
    state = %{
      handlers: init_args.handlers,
      subscription: init_args.subscription,
      max_demand: init_args.max,
      min_demand: init_args.min
    }

    {:consumer, state,
     subscribe_to: [
       {state.subscription, min_demand: state.min_demand, max_demand: state.max_demand}
     ]}
  end

  def handle_events(messages, _from, %{handlers: handlers} = state) do
    Enum.reduce(handlers, messages, &apply_handler/2)

    {:noreply, [], state}
  end

  def handle_info(_, state), do: {:noreply, [], state}

  defp apply_handler({module, function, args}, messages) do
    Enum.map(messages, fn message -> apply(module, function, [message] ++ args) end)
  end

  defp apply_handler(function, messages) when is_function(function) do
    Enum.map(messages, fn message -> apply(function, [message]) end)
  end
end
