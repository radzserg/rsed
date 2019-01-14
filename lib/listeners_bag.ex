defmodule Rsed.ListenersBag do

  @doc """
  Add subscriber subscriber callbacks to listeners bag

      listeners = Rsed.ListenersBag.add_subscriber(%{}, Rsed.Test.TestSubscriber2)
  """
  @spec add_subscriber(listeners :: map(), subscriber :: module()) :: map()
  def add_subscriber(listeners, subscriber) do
    subscriber_listeners = Enum.flat_map(subscriber.get_subscriber_events(), fn ({name, callback})  ->
      add_subscriber_callbacks(name, subscriber, callback)
    end)

    Enum.group_by(
      subscriber_listeners,
      fn({event_name, _callback, _priority}) ->
        event_name
      end,
      fn({_event_name, {module, fun_name}, priority}) ->
        {module, fun_name, priority}
      end
    )
    |> merge_listeners(listeners)
  end

  @spec add_listener(listeners :: map(), event_name :: atom(), {module :: module(), callback :: atom()}, priority :: integer()) :: map()
  def add_listener(listeners, event_name, {module, callback}, priority \\ 0) do
    new_listeners = %{
      event_name => [{module, callback, priority}]
    }
    |> merge_listeners(listeners)
  end

  defp merge_listeners(new_listeners, listeners) do
    {_, listeners} = Enum.map_reduce(new_listeners, listeners, fn({event_name, subscriber_listeners}, listeners) ->
      event_listeners = Map.get(listeners, event_name, [])
      merged_event_listeners = event_listeners ++ subscriber_listeners
      |> Enum.sort(fn({_, _, order1}, {_, _, order2}) -> order1 < order2 end)

      listeners = Map.put(listeners, event_name, merged_event_listeners)
      {nil, listeners}
    end)
    listeners
  end

  defp add_subscriber_callbacks(event_name, subscriber, callbacks) when is_list(callbacks) do
    Enum.map(callbacks, fn({callback, priority}) ->
      {event_name, {subscriber, callback}, priority}
    end)
  end
  defp add_subscriber_callbacks(event_name, subscriber, callback) do
    [{event_name, {subscriber, callback}, 0}]
  end

end
