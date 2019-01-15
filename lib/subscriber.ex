defmodule Rsed.Subscriber do
  @doc """
  Returns a map between event name and own event handlers

      defmodule Rsed.Test.TestSubscriber2 do
        @behaviour Rsed.Subscriber

        def get_subscriber_events() do
          %{
            test_event_2: :handler_2,
            test_event_3: :handler_3,
            test_event_4: [
              handler_4: 200,
              handler_5: 100
            ]
          }
        end

        def handler_2(event = %Rsed.Event{}), do: nil
        def handler_3(event = %Rsed.Event{}), do: nil
        def handler_4(event = %Rsed.Event{}), do: nil
        def handler_5(event = %Rsed.Event{}), do: nil
      end
  """
  @callback get_subscriber_events() :: map()
end
