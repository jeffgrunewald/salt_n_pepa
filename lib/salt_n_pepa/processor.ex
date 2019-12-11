defmodule SaltNPepa.Processor do
  @moduledoc """
  TODO
  """

  use GenStage

  def start_link(init_args) do
    GenStage.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(init_args) do
    state = %{
      subscription: init_args.subscription,
      max_demand: init_args.max,
      min_demand: init_args.min
    }

    {:producer_consumer, state,
     subscribe_to: [
       {state.subscription, min_demand: state.min_demand, max_demand: state.max_demand}
     ]}
  end

  def handle_events(messages, _from, state) do
    decoded_messages = Enum.map(messages, &Jason.decode!/1)

    {:noreply, decoded_messages, state}
  end

  def handle_info(_, state), do: {:noreply, [], state}
end
